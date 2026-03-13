import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/snapd/snapd_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'installed_snaps_provider.g.dart';

@riverpod
class InstalledSnaps extends _$InstalledSnaps {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapListState> build() async {
    return connectionCheck(_snapd.getSnaps, ref);
  }

  // Used to add a snap from the list without reloading the whole provider.
  // Should be used when a snap is uninstalled directly from the manage page
  // list for example.
  Future<void> addToList(Snap snap) async {
    if (!state.hasValue) return;
    final localSnap = await _snapd.getSnap(snap.name);
    state = AsyncData(
      state.value!.copyWith(
        snaps: [...state.value!.snaps, localSnap],
      ),
    );
  }

  // Used to remove a snap from the list without reloading the whole provider.
  // Should be used when a snap is uninstalled directly from the manage page
  // list for example.
  void removeFromList(String snapName) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.copyWith(
        snaps: state.value!.snaps.where((s) => s.name != snapName),
      ),
    );
  }
}
