import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final storeSnapProvider =
    StreamProvider.autoDispose.family<Snap?, String>((ref, String snapName) {
  final snapd = getService<SnapdService>();
  return snapd.getStoreSnap(snapName);
});

final localSnapProvider =
    StateNotifierProvider.family<LocalSnapNotifier, LocalSnap, String>(
        (ref, String snapName) {
  final snapd = getService<SnapdService>();
  return LocalSnapNotifier(snapd, snapName)..init();
});

final selectedChannelProvider = StateProvider.autoDispose
    .family<String?, String>((ref, snapName) =>
        ref.watch(storeSnapProvider(snapName)).whenOrNull(data: (storeSnap) {
          final channels = storeSnap?.channels.keys;
          final localChannel = ref
              .watch(localSnapProvider(snapName))
              .whenOrNull(data: (localSnap) => localSnap.channel);
          if (localChannel != null &&
              (channels?.contains(localChannel) ?? false)) {
            return localChannel;
          }
          if (channels?.contains('latest/stable') ?? false) {
            return 'latest/stable';
          }
          return channels?.firstWhereOrNull((c) => c.contains('stable')) ??
              channels?.firstOrNull;
        }));

typedef LocalSnap = AsyncValue<Snap>;

class LocalSnapNotifier extends StateNotifier<LocalSnap> {
  LocalSnapNotifier(this.snapd, this.snapName)
      : super(const LocalSnap.loading());

  final SnapdService snapd;
  final String snapName;

  Future<void> init() => _getLocalSnap();

  Future<void> _getLocalSnap() async {
    state = await LocalSnap.guard(() => snapd.getSnap(snapName));
  }

  Future<void> install({String? channel}) async {
    state = const LocalSnap.loading();
    await snapd.install(snapName, channel: channel).then(snapd.waitChange);
    return _getLocalSnap();
  }

  Future<void> refresh({String? channel}) async {
    state = const LocalSnap.loading();
    await snapd.refresh(snapName, channel: channel).then(snapd.waitChange);
    return _getLocalSnap();
  }

  Future<void> remove() async {
    state = const LocalSnap.loading();
    await snapd.remove(snapName).then(snapd.waitChange);
    return _getLocalSnap();
  }
}
