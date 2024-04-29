import 'dart:async';

import 'package:app_center/snapd.dart';
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

final activeChangeIdProvider = StateProvider.family<String?, String>(
  (ref, name) => null,
);

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

@immutable
class SnapData {
  SnapData({
    required this.name,
    required this.localSnap,
    required this.storeSnap,
    this.activeChangeId,
    String? selectedChannel,
  }) : selectedChannel =
            selectedChannel ?? _defaultSelectedChannel(localSnap, storeSnap);

  final String name;
  final Snap? localSnap;
  final Snap? storeSnap;
  final String? selectedChannel;
  final String? activeChangeId;

  Snap get snap => storeSnap ?? localSnap!;
  SnapChannel? get channelInfo => storeSnap?.channels[selectedChannel];
  bool get isInstalled => localSnap != null;
  bool get hasGallery =>
      storeSnap != null && storeSnap!.screenshotUrls.isNotEmpty;
  Map<String, SnapChannel>? get availableChannels => storeSnap?.channels;

  VoidCallback? callback(
    WidgetRef ref,
    SnapAction action, [
    SnapLauncher? launcher,
  ]) {
    return switch (action) {
      SnapAction.cancel => () => ref.read(snapAbortProvider(name)),
      SnapAction.install =>
        storeSnap != null ? () => ref.read(snapInstallProvider(name)) : null,
      SnapAction.open =>
        launcher?.isLaunchable ?? false ? launcher!.open : null,
      SnapAction.remove => () => ref.read(snapRemoveProvider(name)),
      SnapAction.switchChannel =>
        storeSnap != null ? () => ref.read(snapRefreshProvider(this)) : null,
      SnapAction.update =>
        storeSnap != null ? () => ref.read(snapRefreshProvider(this)) : null,
    };
  }

  static String? _defaultSelectedChannel(Snap? localSnap, Snap? storeSnap) {
    final channels = storeSnap?.channels.keys;
    final localChannel = localSnap?.trackingChannel;
    if (localChannel != null && (channels?.contains(localChannel) ?? false)) {
      return localChannel;
    } else if (channels?.contains('latest/stable') ?? false) {
      return 'latest/stable';
    } else {
      return channels?.firstWhereOrNull((c) => c.contains('stable')) ??
          channels?.firstOrNull;
    }
  }
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
