import 'package:app_center/manage/manage_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';

part 'local_snap_providers.g.dart';

final localSnapFilterProvider = StateProvider.autoDispose<String>((_) => '');
final showLocalSystemAppsProvider = StateProvider<bool>((_) => false);
final localSnapSortOrderProvider =
    StateProvider<SnapSortOrder>((_) => SnapSortOrder.alphabeticalAsc);

@riverpod
class FilteredLocalSnaps extends _$FilteredLocalSnaps {
  @override
  Future<Iterable<Snap>> build() async {
    final nonRefreshableSnaps = await ref.watch(
      manageModelProvider.future.select(
        (m) => m.then((value) => value.nonRefreshableSnaps),
      ),
    );
    void refreshFunction(_, __) => _refreshWithFilters(nonRefreshableSnaps);
    ref.listen(localSnapFilterProvider, refreshFunction);
    ref.listen(showLocalSystemAppsProvider, refreshFunction);
    ref.listen(localSnapSortOrderProvider, refreshFunction);
    return _refreshWithFilters(nonRefreshableSnaps, updateState: false);
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
        .sortedSnaps(sortOrder);
    if (updateState) {
      state = AsyncData(filteredSnaps);
    }
    return filteredSnaps;
  }
}
