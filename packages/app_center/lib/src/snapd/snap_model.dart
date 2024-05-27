import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/snap_data.dart';
import 'package:app_center/src/snapd/snapd_cache.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'snap_model.g.dart';

@riverpod
class SnapPackage extends _$SnapPackage {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapData> build({required String snapName}) async {
    Snap? localSnap;
    try {
      localSnap = await getService<SnapdService>().getSnap(snapName);
    } on SnapdException catch (e) {
      if (e.kind != 'snap-not-found') rethrow;
    }

    final storeSnap = ref.watch(storeSnapProvider(snapName)).value;
    if (localSnap == null) {
      await ref.read(storeSnapProvider(snapName).future);
    }
    return SnapData(
      name: snapName,
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
  }

  Future<void> install() async {
    if (!state.hasValue) {
      throw PrematureSnapOperationException();
    }
    final model = state.value;
    final storeSnap = model?.storeSnap;
    final selectedChannel = model?.selectedChannel;

    if (storeSnap?.channels[selectedChannel] == null) {
      throw PrematureSnapOperationException();
    }
    final changeId = await _snapd.install(
      snapName,
      channel: selectedChannel,
      classic: storeSnap!.channels[selectedChannel]!.confinement ==
          SnapConfinement.classic,
    );
    _updateChangeId(changeId);
    return _listenUntilDone(changeId, snapName, ref);
  }

  Future<void> abort() async {
    final changeIdToAbort = state.value?.activeChangeId;
    if (changeIdToAbort == null) {
      return;
    }
    final changeId = (await _snapd.abortChange(changeIdToAbort)).id;
    _updateChangeId(changeId);
    return _listenUntilDone(changeId, snapName, ref);
  }

  Future<void> refresh() async {
    final snapData = state.asData?.valueOrNull;
    final storeSnap = snapData?.storeSnap;
    final selectedChannel = snapData?.selectedChannel;

    if (snapData == null || storeSnap?.channels[selectedChannel] == null) {
      throw PrematureSnapOperationException();
    }

    final changeId = await _snapd.refresh(
      snapData.name,
      channel: selectedChannel,
      classic: storeSnap!.channels[selectedChannel]!.confinement ==
          SnapConfinement.classic,
    );
    _updateChangeId(changeId);
    return _listenUntilDone(changeId, snapData.name, ref);
  }

  Future<void> remove() async {
    final changeId = await getService<SnapdService>().remove(snapName);
    _updateChangeId(changeId);
    return _listenUntilDone(changeId, snapName, ref);
  }

  void selectChannel(String channel) {
    final data = state.asData?.valueOrNull;
    if (data != null) {
      state = AsyncData(data.copyWith(selectedChannel: channel));
    }
  }

  void Function()? callback(
    WidgetRef ref,
    SnapAction action, [
    SnapLauncher? launcher,
  ]) {
    return switch (action) {
      SnapAction.cancel => abort,
      SnapAction.install =>
        state.valueOrNull?.storeSnap != null ? install : null,
      SnapAction.open =>
        launcher?.isLaunchable ?? false ? launcher!.open : null,
      SnapAction.remove => remove,
      SnapAction.switchChannel =>
        state.valueOrNull?.storeSnap != null ? refresh : null,
      SnapAction.update =>
        state.valueOrNull?.storeSnap != null ? refresh : null,
    };
  }

  void _updateChangeId(String? changeId) {
    final data = state.asData?.valueOrNull;
    if (data != null) {
      state = AsyncData(data.copyWith(activeChangeId: changeId));
    }
  }

  Future<void> _listenUntilDone(String changeId, String snapName, Ref ref) {
    final completer = Completer();
    _snapd.watchChange(changeId).listen((event) {
      if (event.err != null) {
        completer.completeError(event.err!);
      } else if (event.ready) {
        completer.complete();
      }
    });
    return completer.future.whenComplete(() => _updateChangeId(null));
  }
}

/// Provides the progress of the snapd operations for the given change IDs.
final progressProvider =
    StreamProvider.family.autoDispose<double, List<String>>((ref, ids) {
  final snapd = getService<SnapdService>();

  final streamController = StreamController<double>.broadcast();
  final subProgresses = <String, double>{for (final id in ids) id: 0.0};
  final subscriptions = <String, StreamSubscription<SnapdChange>>{
    for (final id in ids)
      id: snapd.watchChange(id).listen((change) {
        subProgresses[id] = change.progress;
        streamController.add(subProgresses.values.sum / subProgresses.length);
      })
  };
  ref.onDispose(() {
    for (final subscription in subscriptions.values) {
      subscription.cancel();
    }
    streamController.close();
  });
  return streamController.stream;
});

/// Provides the active change, if any, for a given snap.
final activeChangeProvider =
    StateProvider.family<SnapdChange?, String?>((ref, id) {
  if (id == null) return null;
  late final StreamSubscription<SnapdChange> subscription;
  subscription = getService<SnapdService>().watchChange(id).listen((event) {
    ref.controller.state = event;
    if (event.ready) {
      subscription.cancel();
    }
  });
  ref.onDispose(subscription.cancel);
  return null;
});

extension SnapdChangeX on SnapdChange {
  double get progress {
    var done = 0.0;
    var total = 0.0;
    for (final task in tasks) {
      done += task.progress.done;
      total += task.progress.total;
    }

    return total != 0 ? done / total : 0;
  }
}

class PrematureSnapOperationException implements Exception {
  @override
  String toString() {
    return 'The operation can not be performed before the snap is loaded';
  }
}
