import 'dart:async';

import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/snapd/currently_installing_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/snapd/snapd_cache.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'snap_model.g.dart';

@Riverpod(keepAlive: true)
class SnapModel extends _$SnapModel {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapData> build(String snapName) async {
    Snap? localSnap;
    try {
      localSnap = await _snapd.getSnap(snapName);
    } on SnapdException catch (e) {
      switch (e.kind) {
        // Since the snap is just not installed when 'snap-not-found is thrown
        // we can ignore this exception.
        case 'snap-not-found':
        // When kind is null it is most likely a problem with the internet
        // connection.
        case 'network-timeout':
        case null:
          break;
        default:
          rethrow;
      }
    }

    final storeSnap = await ref
        .watch(storeSnapProvider(snapName).future)
        .onError((_, __) => null, test: (_) => localSnap != null);

    final activeChangeId = (await _snapd.getChanges(name: snapName))
        .firstWhereOrNull((change) => !change.ready)
        ?.id;
    if (activeChangeId != null) {
      unawaited(_listenUntilDone(activeChangeId, ref));
    }

    if (localSnap == null && storeSnap == null) {
      // This only happens when you have installed a local snap that you then
      // later remove, it results in that there isn't any metadata left
      // regarding it.
      throw SnapDataNotFoundException(snapName);
    }
    final hasUpdate = ref.watch(hasUpdateProvider(snapName));

    // Determine if a previous local revision exists to enable revert
    final hasPrev = await _snapd.hasPreviousRevision(snapName);

    return SnapData(
      name: snapName,
      localSnap: localSnap,
      storeSnap: storeSnap,
      activeChangeId: activeChangeId,
      selectedChannel: SnapData.defaultSelectedChannel(
        localSnap,
        storeSnap,
      ),
      hasUpdate: hasUpdate,
      hasPreviousLocalRevision: hasPrev,
    );
  }

  /// Installs the selected snap from the selected channel.
  Future<void> install() async {
    assert(
      state.hasStoreSnap,
      'The snap must be loaded from the store before installing it',
    );
    final model = state.value;
    final storeSnap = model?.storeSnap;
    final selectedChannel = model?.selectedChannel;

    assert(
      storeSnap?.channels[selectedChannel] != null,
      'Invalid channel or not fully loaded store snap $selectedChannel',
    );
    final changeId = await _snapd.install(
      snapName,
      channel: selectedChannel,
      classic: storeSnap!.channels[selectedChannel]!.confinement ==
          SnapConfinement.classic,
    );
    ref.read(currentlyInstallingModelProvider.notifier).add(snapName, model!);
    _updateChangeId(changeId);
    await _listenUntilDone(changeId, ref);
    unawaited(
      ref.read(filteredLocalSnapsProvider.notifier).addToList(storeSnap),
    );
  }

  /// Cancels (aborts) the currently active operation which is tracked by
  /// the `activeChangeId`.
  Future<void> cancel() async {
    assert(
      state.hasStoreSnap,
      'The snap must be loaded from the store before aborting an action',
    );
    final changeIdToAbort = state.value?.activeChangeId;
    if (changeIdToAbort == null) {
      return;
    }
    final changeId = (await _snapd.abortChange(changeIdToAbort)).id;
    _updateChangeId(changeId);
    await _listenUntilDone(changeId, ref, invalidate: false);
  }

  /// Updates the version of the snap.
  ///
  /// Returns `true` if the snap was updated, `false` otherwise.
  Future<bool> refresh({bool removeFromList = false}) async {
    assert(
      state.hasStoreSnap,
      'The snap must be loaded from the store before updating it',
    );
    final snapData = state.value!;
    final storeSnap = snapData.storeSnap;
    final selectedChannel = snapData.selectedChannel;

    final changeId = await _snapd.refresh(
      snapData.name,
      channel: selectedChannel,
      classic: storeSnap!.channels[selectedChannel]!.confinement ==
          SnapConfinement.classic,
    );
    _updateChangeId(changeId);
    return _listenUntilDone(changeId, ref).then((completedSuccessfully) {
      if (removeFromList && completedSuccessfully) {
        ref.read(updatesModelProvider.notifier).removeFromList(snapData.name);
        ref
            .read(filteredLocalSnapsProvider.notifier)
            .addToList(snapData.localSnap!);
      }
      return completedSuccessfully;
    });
  }

  /// Uninstalls the snap.
  Future<void> remove() async {
    assert(state.hasValue, 'The snap must be loaded before removing it');
    final changeId = await _snapd.remove(snapName);
    _updateChangeId(changeId);
    await _listenUntilDone(changeId, ref);
    ref.read(updatesModelProvider.notifier).removeFromList(snapName);
    ref.read(filteredLocalSnapsProvider.notifier).removeFromList(snapName);
  }

  Future<void> revert() async {
    assert(state.hasValue, 'The snap must be loaded before reverting it');
    assert(
      state.value!.isInstalled, // safe: hasValue asserted above
      'The snap must be installed before reverting it',
    );

    // Optimistically hide the Revert action to prevent multiple consecutive reverts
    final currentData = state.value!;
    state = AsyncData(currentData.copyWith(hasPreviousLocalRevision: false));

    try {
      final changeId = await _snapd.revert(snapName);
      _updateChangeId(changeId);
      await _listenUntilDone(changeId, ref);
    } on SnapdException catch (e) {
      // If snapd says there is no revision to revert to, keep UI consistent
      if (e.statusCode == 400 &&
          e.message.contains('no revision to revert to')) {
        ref.invalidateSelf();
        return;
      }

      // For other errors, restore previous state and rethrow to be handled upstream
      state = AsyncData(currentData.copyWith(hasPreviousLocalRevision: true));
      rethrow;
    }

    // After revert, refresh the snap data to reflect the new version
    ref.invalidateSelf();
  }

  /// Changes the selected channel.
  Future<void> selectChannel(String channel) async {
    assert(
      state.hasStoreSnap,
      'The snap must be loaded from the store before changing channel',
    );
    final data = state.value!;
    state = AsyncData(data.copyWith(selectedChannel: channel));
  }

  void _updateChangeId(String changeId) {
    final data = state.value;
    if (data != null) {
      state = AsyncData(data.copyWith(activeChangeId: changeId));
    }
  }

  void _removeChangeId(String changeId) {
    final data = state.value;
    if (data != null && data.activeChangeId == changeId) {
      state = AsyncData(data.copyWith(activeChangeId: null));
    }
  }

  Future<bool> _listenUntilDone(
    String changeId,
    Ref ref, {
    bool invalidate = true,
    void Function()? onSuccess,
  }) async {
    var completedSuccessfully = false;
    final completer = Completer();
    final subscription = _snapd.watchChange(changeId).listen((event) {
      if (event.err != null) {
        completer.completeError(event.err!);
      } else if (event.ready) {
        completer.complete();
        completedSuccessfully = true;
        onSuccess?.call();
      }
    });
    await completer.future.whenComplete(() {
      subscription.cancel();
      _removeChangeId(changeId);
    });
    if (invalidate) {
      ref.invalidateSelf();
    }
    return completedSuccessfully;
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
      }),
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

extension on AsyncValue<SnapData> {
  bool get hasStoreSnap => valueOrNull?.storeSnap != null;
}

class SnapDataNotFoundException implements Exception {
  SnapDataNotFoundException(this.message);

  final String message;

  @override
  String toString() => 'SnapDataNotFoundException: $message';
}
