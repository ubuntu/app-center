import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/providers/installed_snaps_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_snap_providers.g.dart';

final localSnapFilterProvider = StateProvider.autoDispose<String>((_) => '');
final showLocalSystemAppsProvider = StateProvider<bool>((_) => false);
final localSnapSortOrderProvider =
    StateProvider<SnapSortOrder>((_) => SnapSortOrder.alphabeticalAsc);

@riverpod
Future<SnapListState> filteredLocalSnaps(Ref ref) async {
  final installedState = await ref.watch(installedSnapsProvider.future);

  final filter = ref.watch(localSnapFilterProvider).toLowerCase();
  final showSystemApps = ref.watch(showLocalSystemAppsProvider);
  final sortOrder = ref.watch(localSnapSortOrderProvider);

  final updates = await ref.watch(updatesModelProvider.future);
  final updateNames = updates.snaps.map((s) => s.name).toSet();

  final filteredSnaps = installedState.snaps
      .where((s) => !updateNames.contains(s.name))
      .where((s) =>
          s.titleOrName.toLowerCase().contains(filter) &&
          (showSystemApps || s.apps.isNotEmpty))
      .toSet()
      .sortedSnaps(sortOrder);

  return installedState.copyWith(snaps: filteredSnaps);
}
