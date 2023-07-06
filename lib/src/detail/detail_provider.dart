import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final storeSnapProvider =
    FutureProvider.autoDispose.family<Snap, String>((ref, String snapName) {
  final snapd = getService<SnapdService>();
  return snapd.find(name: snapName).then((r) => r.single);
});

final detailModelProvider = StateNotifierProvider.autoDispose
    .family<DetailNotifier, DetailState, String>((ref, String snapName) {
  final snapd = getService<SnapdService>();
  return DetailNotifier(snapd, snapName)..init();
});

typedef DetailState = AsyncValue<Snap>;

class DetailNotifier extends StateNotifier<DetailState> {
  DetailNotifier(this.snapd, this.snapName)
      : super(const DetailState.loading());

  final SnapdService snapd;
  final String snapName;

  Future<void> init() => _getLocalSnap();

  Future<void> _getLocalSnap() async {
    state = await DetailState.guard(() => snapd.getSnap(snapName));
  }

  Future<void> install() async {
    state = const DetailState.loading();
    await snapd.install(snapName).then(snapd.waitChange);
    return _getLocalSnap();
  }

  Future<void> remove() async {
    state = const DetailState.loading();
    await snapd.remove(snapName).then(snapd.waitChange);
    return _getLocalSnap();
  }
}
