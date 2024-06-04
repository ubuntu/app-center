import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/snap_data.dart';
import 'package:app_center/src/snapd/snapd_cache.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'snap_model.g.dart';

@Riverpod(keepAlive: true)
class SnapPackage extends _$SnapPackage {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapData> build(String snapName) async {
    Snap? localSnap;
    try {
      localSnap = await getService<SnapdService>().getSnap(snapName);
    } on SnapdException catch (e) {
      if (e.kind != 'snap-not-found') rethrow;
    }

    final Snap? storeSnap;
    if (localSnap == null) {
      // If we don't have a local snap we keep the provider in loading until the
      // store snap is loaded.
      storeSnap = await ref.watch(storeSnapProvider(snapName).future);
    } else {
      // Since we have a local snap we don't need to wait for the store snap to
      // be loaded, but the store snap will be updated in the data once it is.
      storeSnap = ref.watch(storeSnapProvider(snapName)).valueOrNull;
    }

    final activeChangeId = (await _snapd.getChanges(name: snapName))
        .firstWhereOrNull((change) => !change.ready)
        ?.id;
    if (activeChangeId != null) {
      unawaited(_listenUntilDone(activeChangeId, snapName, ref));
    }

    return SnapData(
      name: snapName,
      localSnap: localSnap,
      storeSnap: storeSnap,
      activeChangeId: activeChangeId,
      selectedChannel: SnapData.defaultSelectedChannel(localSnap, storeSnap),
    );
  }

  Future<void> install() async {
    if (!state.hasValue) {
      await future;
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
    if (!state.hasValue) {
      await future;
    }
    final changeIdToAbort = state.value?.activeChangeId;
    if (changeIdToAbort == null) {
      return;
    }
    final changeId = (await _snapd.abortChange(changeIdToAbort)).id;
    _updateChangeId(changeId);
    return _listenUntilDone(changeId, snapName, ref);
  }

  Future<void> refresh() async {
    if (!state.hasValue) {
      await future;
    }
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
    if (!state.hasValue) {
      await future;
    }
    final changeId = await getService<SnapdService>().remove(snapName);
    _updateChangeId(changeId);
    return _listenUntilDone(changeId, snapName, ref);
  }

  Future<void> selectChannel(String channel) async {
    if (!state.hasValue) {
      await future;
    }
    final data = state.asData?.valueOrNull;
    if (data != null) {
      state = AsyncData(data.copyWith(selectedChannel: channel));
    } else {
      // TODO: Throw an error?
    }
  }

  // TODO: Remove if not used
  @visibleForTesting
  Future<void> fullyLoad() async {
    if (state.isLoading) {
      await future;
    }
    final data = state.asData?.valueOrNull;
    if (data != null) {
      final storeSnap = await ref.read(storeSnapProvider(data.name).future);
      state = AsyncData(data.copyWith(storeSnap: storeSnap));
    }
  }

  @visibleForTesting
  void setValues({
    bool? hasUpdate,
    Snap? localSnap,
    Snap? storeSnap,
    String? selectedChannel,
    String? snapName,
    String? activeChangeId,
    AsyncValue<SnapData>? mockState,
  }) {
    if (mockState != null) {
      state = mockState;
    }
    state = AsyncData(SnapData(
      name: snapName ?? localSnap?.name ?? storeSnap?.name ?? '',
      localSnap: localSnap,
      storeSnap: storeSnap,
      selectedChannel:
          selectedChannel ?? localSnap?.trackingChannel ?? 'latest/stable',
      activeChangeId: activeChangeId,
    ));
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
      // TODO: This must surely be wrong?
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

/// Provides the active change, if any, for a given changeId.
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
