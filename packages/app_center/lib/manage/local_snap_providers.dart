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

// TODO: Maybe rename since it is filtered?
@riverpod
class LocalSnaps extends _$LocalSnaps {
  @override
  Future<Iterable<Snap>> build() async {
    final nonRefreshableSnaps = await ref.watch(
      manageModelProvider.future.select(
        (m) => m.then((value) => value.nonRefreshableSnaps),
      ),
    );
    return nonRefreshableSnaps
        .where(
          (snap) => snap.titleOrName
              .toLowerCase()
              .contains(ref.watch(localSnapFilterProvider).toLowerCase()),
        )
        .where(
          (snap) =>
              ref.watch(showLocalSystemAppsProvider) || snap.apps.isNotEmpty,
        )
        .sortedSnaps(ref.watch(localSnapSortOrderProvider));
  }
}
