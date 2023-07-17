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

  Future<void> install() async {
    state = const LocalSnap.loading();
    await snapd.install(snapName).then(snapd.waitChange);
    return _getLocalSnap();
  }

  Future<void> refresh() async {
    state = const LocalSnap.loading();
    await snapd.refresh(snapName).then(snapd.waitChange);
    return _getLocalSnap();
  }

  Future<void> remove() async {
    state = const LocalSnap.loading();
    await snapd.remove(snapName).then(snapd.waitChange);
    return _getLocalSnap();
  }
}
