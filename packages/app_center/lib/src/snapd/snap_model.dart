import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/snap_data.dart';
import 'package:app_center/src/snapd/snapd_cache.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

/// Used to fetch the meta data for a snap from both the store and the local
/// system.
final snapDataProvider = FutureProvider.family<SnapData, String>(
  (ref, snapName) async {
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
    final activeSnapChangeId = ref.watch(activeChangeIdProvider(snapName));
    final selectedChannel = ref.read(selectedChannelProvider(snapName));
    return SnapData(
      name: snapName,
      localSnap: localSnap,
      storeSnap: storeSnap,
      activeChangeId: activeSnapChangeId,
      selectedChannel: selectedChannel,
    );
  },
);

/// Provides the selected channel for a given snap.
final selectedChannelProvider = StateProvider.family<String?, String>(
  (ref, snapName) => null,
);

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

/// Provides the active change ID, if any, for a given snap.
@visibleForTesting
final activeChangeIdProvider = StateProvider.family<String?, String>(
  (ref, name) => null,
);

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

//#region Snap operations

/// Initiates the installation of the snap with the given name.
final snapInstallProvider =
    FutureProvider.family<void, String>((ref, snapName) async {
  final model = ref.read(snapDataProvider(snapName)).value;
  final storeSnap = model?.storeSnap;
  final selectedChannel = model?.selectedChannel;
  final snapd = getService<SnapdService>();

  assert(
    storeSnap?.channels[selectedChannel] != null,
    'install() should not be called before the store snap is available',
  );
  final changeId = await snapd.install(
    snapName,
    channel: selectedChannel,
    classic: storeSnap!.channels[selectedChannel]!.confinement ==
        SnapConfinement.classic,
  );
  ref.read(activeChangeIdProvider(snapName).notifier).state = changeId;
  return _listenUntilDone(changeId, snapName, ref);
});

/// Aborts the active change for the given snap.
final snapAbortProvider = FutureProvider.family<void, String>(
  (ref, snapName) async {
    final changeIdToAbort = ref.read(activeChangeIdProvider(snapName));
    if (changeIdToAbort == null) {
      return;
    }
    final snapd = getService<SnapdService>();
    final changeId = (await snapd.abortChange(changeIdToAbort)).id;
    ref.read(activeChangeIdProvider(snapName).notifier).state = changeId;
    return _listenUntilDone(changeId, snapName, ref);
  },
);

/// Initiates the refresh/update of the snap with the given name.
final snapRefreshProvider =
    FutureProvider.family<void, SnapData>((ref, snapData) async {
  final storeSnap = snapData.storeSnap;
  final selectedChannel = snapData.selectedChannel;
  final snapd = getService<SnapdService>();

  assert(
    storeSnap?.channels[selectedChannel] != null,
    'refresh() should not be called before the store snap is available',
  );
  final changeId = await snapd.refresh(
    snapData.name,
    channel: selectedChannel,
    classic: storeSnap!.channels[selectedChannel]!.confinement ==
        SnapConfinement.classic,
  );
  ref.read(activeChangeIdProvider(snapData.name).notifier).state = changeId;
  return _listenUntilDone(changeId, snapData.name, ref);
});

/// Initiates the removal of the snap with the given name.
final snapRemoveProvider =
    FutureProvider.family<void, String>((ref, snapName) async {
  final changeId = await getService<SnapdService>().remove(snapName);
  ref.read(activeChangeIdProvider(snapName).notifier).state = changeId;
  return _listenUntilDone(changeId, snapName, ref);
});

//#endregion

Future<void> _listenUntilDone(String changeId, String snapName, Ref ref) {
  final completer = Completer();
  getService<SnapdService>().watchChange(changeId).listen((event) {
    if (event.err != null) {
      completer.completeError(event.err!);
    } else if (event.ready) {
      completer.complete();
    }
  });
  return completer.future.whenComplete(
    () => ref.read(activeChangeIdProvider(snapName).notifier).state = null,
  );
}

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
