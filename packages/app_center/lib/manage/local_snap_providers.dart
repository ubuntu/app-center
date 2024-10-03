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
    final snapListState = await connectionCheck(_snapd.getSnaps, ref);
    final snaps = snapListState.snaps;
    final refreshableSnaps =
        (await ref.read(updatesModelProvider.future)).snaps.map((s) => s.name);
    final nonRefreshableSnaps =
        snaps.where((s) => !refreshableSnaps.contains(s.name));
    void refreshFunction(_, __) => _refreshWithFilters(nonRefreshableSnaps);
    ref.listen(localSnapFilterProvider, refreshFunction);
    ref.listen(showLocalSystemAppsProvider, refreshFunction);
    ref.listen(localSnapSortOrderProvider, refreshFunction);
    return snapListState.copyWith(
      snaps: _refreshWithFilters(nonRefreshableSnaps, updateState: false),
    );
  }

  /// Used to add a snap from the list without reloading the whole provider.
  /// Should be used when a snap is uninstalled directly from the manage page
  /// list for example.
  Future<void> addToList(Snap snap) async {
    if (!state.hasValue) return;
    final localSnap = await _snapd.getSnap(snap.name);
    _refreshWithFilters([...state.value!.snaps, localSnap]);
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

  Iterable<Snap> _refreshWithFilters(
    Iterable<Snap> nonRefreshableSnaps, {
    bool updateState = true,
  }) {
    final filter = ref.read(localSnapFilterProvider).toLowerCase();
    final showSystemApps = ref.read(showLocalSystemAppsProvider);
    final sortOrder = ref.read(localSnapSortOrderProvider);
    final filteredSnaps = nonRefreshableSnaps
        .where(
          (snap) =>
              snap.titleOrName.toLowerCase().contains(filter) &&
              (showSystemApps || snap.apps.isNotEmpty),
        )
        .toSet()
        .sortedSnaps(sortOrder);
    if (updateState) {
      state = AsyncData(
        SnapListState(
          snaps: filteredSnaps,
          hasInternet: state.value?.hasInternet ?? true,
        ),
      );
    }
    return filteredSnaps;
  }
}
