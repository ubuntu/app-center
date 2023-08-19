import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/snapd.dart';
import 'manage_model.dart';

final localSnapFilterProvider = StateProvider.autoDispose<String>((_) => '');
final showLocalSystemAppsProvider = StateProvider<bool>((_) => false);
final localSnapSortOrderProvider =
    StateProvider<SnapSortOrder>((_) => SnapSortOrder.alphabeticalAsc);
final localSnapsProvider = Provider.autoDispose(
  (ref) => ref
      .watch(manageModelProvider.select((m) => m.nonRefreshableSnaps))
      .where((snap) => snap.titleOrName
          .toLowerCase()
          .contains(ref.watch(localSnapFilterProvider).toLowerCase()))
      .where((snap) =>
          ref.watch(showLocalSystemAppsProvider) || snap.apps.isNotEmpty)
      .sortedSnaps(ref.watch(localSnapSortOrderProvider)),
);
