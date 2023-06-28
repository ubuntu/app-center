import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final detailModelProvider = StateNotifierProvider.autoDispose
    .family<DetailNotifier, DetailState, Snap>((ref, Snap storeSnap) {
  final snapd = getService<SnapdService>();
  return DetailNotifier(snapd, storeSnap)..init();
});

typedef DetailState = AsyncValue<Snap>;

class DetailNotifier extends StateNotifier<DetailState> {
  DetailNotifier(this.snapd, this.storeSnap)
      : super(const DetailState.loading());

  final SnapdService snapd;
  final Snap storeSnap;

  Future<void> init() => _getLocalSnap();

  Future<void> _getLocalSnap() async {
    state = await DetailState.guard(() => snapd.getSnap(storeSnap.name));
  }

  Future<void> install() async {
    state = const DetailState.loading();
    await snapd.install(storeSnap.name).then(snapd.waitChange);
    return _getLocalSnap();
  }

  Future<void> remove() async {
    state = const DetailState.loading();
    await snapd.remove(storeSnap.name).then(snapd.waitChange);
    return _getLocalSnap();
  }
}
