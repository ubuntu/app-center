import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

sealed class DetailState {
  const factory DetailState.loading() = LoadingState;
  const factory DetailState.error(String message) = ErrorState;
  const factory DetailState.data(Snap localSnap) = DataState;
}

class LoadingState implements DetailState {
  const LoadingState();
}

class ErrorState implements DetailState {
  const ErrorState(this.message);

  final String message;
}

class DataState implements DetailState {
  const DataState(this.localSnap);

  final Snap localSnap;
}

class DetailNotifier extends StateNotifier<DetailState> {
  DetailNotifier(this.snapd, this.storeSnap)
      : super(const DetailState.loading());

  final SnapdService snapd;
  final Snap storeSnap;

  Future<void> init() => _getLocalSnap();

  Future<void> _getLocalSnap() async {
    try {
      final localSnap = await snapd.getSnap(storeSnap.name);
      state = DetailState.data(localSnap);
    } on SnapdException catch (e) {
      state = ErrorState(e.message);
    }
  }

  Future<void> install() async {
    state = const DetailState.loading();
    final changeId = await snapd.install(storeSnap.name);
    await for (final change in snapd.watchChange(changeId)) {
      if (change.ready) break;
    }
    return _getLocalSnap();
  }

  Future<void> remove() async {
    state = const DetailState.loading();
    final changeId = await snapd.remove(storeSnap.name);
    await for (final change in snapd.watchChange(changeId)) {
      if (change.ready) break;
    }
    return _getLocalSnap();
  }
}

final detailModelProvider = StateNotifierProvider.autoDispose
    .family<DetailNotifier, DetailState, Snap>((ref, Snap storeSnap) {
  final snapd = getService<SnapdService>();
  return DetailNotifier(snapd, storeSnap)..init();
});
