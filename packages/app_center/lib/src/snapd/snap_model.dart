import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/snap_data.dart';
import 'package:app_center/src/snapd/snapd_cache.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final snapModelProvider = FutureProvider.family<SnapData, String>(
  (ref, snapName) async {
    final localSnap = await getService<SnapdService>().getSnap(snapName);
    final storeSnap = ref.watch(snapProvider(snapName)).value;
    final activeSnapChangeId =
        ref.watch(activeChangeProvider(snapName)).value?.id;
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

final snapErrorProvider = StateProvider.family<SnapdException?, String>(
  (ref, snapName) => null,
);

final selectedChannelProvider = StateProvider.family<String?, String>(
  (ref, snapName) => null,
);

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

@visibleForTesting
final activeChangeIdProvider = StateProvider.family<String?, String>(
  (ref, name) => null,
);

final activeChangeProvider =
    StreamProvider.family<SnapdChange, String?>((ref, id) {
  if (id == null) return const Stream.empty();
  final controller = StreamController<SnapdChange>.broadcast();
  controller.addStream(getService<SnapdService>().watchChange(id));
  controller.stream.listen((event) {
    if (event.ready) {
      controller.close();
    }
  });
  ref.onDispose(controller.close);
  return controller.stream;
});

final snapInstallProvider =
    FutureProvider.family<void, String>((ref, snapName) async {
  final model = ref.read(snapModelProvider(snapName)).value;
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
});

final snapAbortProvider = FutureProvider.family<void, String>(
  (ref, snapName) async {
    final changeIdToAbort = ref.read(activeChangeIdProvider(snapName));
    if (changeIdToAbort == null) {
      return;
    }
    final snapd = getService<SnapdService>();
    final changeId = (await snapd.abortChange(changeIdToAbort)).id;
    ref.read(activeChangeIdProvider(snapName).notifier).state = changeId;
  },
);

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
});

final snapRemoveProvider =
    FutureProvider.family<void, String>((ref, snapName) async {
  final changeId = await getService<SnapdService>().remove(snapName);
  ref.read(activeChangeIdProvider(snapName).notifier).state = changeId;
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
