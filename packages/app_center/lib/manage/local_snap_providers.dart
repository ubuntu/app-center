import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_snap_providers.g.dart';

final localSnapFilterProvider = StateProvider.autoDispose<String>((_) => '');
final showLocalSystemAppsProvider = StateProvider<bool>((_) => false);
final localSnapSortOrderProvider =
    StateProvider<SnapSortOrder>((_) => SnapSortOrder.alphabeticalAsc);

@riverpod
class FilteredLocalSnaps extends _$FilteredLocalSnaps {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapListState> build() async {
    final snapListState = await ref.watch(localSnapsProvider.future);
    final snaps = snapListState.snaps;
    final refreshableSnaps =
        (await ref.read(updatesModelProvider.future)).snaps.map((s) => s.name);
    final nonRefreshableSnaps =
        snaps.where((s) => !refreshableSnaps.contains(s.name));
    return snapListState.copyWith(snaps: nonRefreshableSnaps);
  }

  /// Used to add a snap from the list without reloading the whole provider.
  /// Should be used when a snap is uninstalled directly from the manage page
  /// list for example.
  Future<void> addToList(Snap snap) async {
    if (!state.hasValue) return;
    final localSnap = await _snapd.getSnap(snap.name);
    state = AsyncData(
      state.value!.copyWith(snaps: [...state.value!.snaps, localSnap]),
    );
  }

  /// Used to remove a snap from the list without reloading the whole provider.
  /// Should be used when a snap is uninstalled directly from the manage page
  /// list for example.
  void removeFromList(String snapName) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.copyWith(
        snaps: state.value!.snaps.where((s) => s.name != snapName),
      ),
    );
  }
}
