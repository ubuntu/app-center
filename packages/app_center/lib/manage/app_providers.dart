import 'package:app_center/manage/deb_updates_model.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/logger.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/snap_updates_model.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'app_providers.g.dart';

/// Controls the sort order for the installed apps list.
final appSortOrderProvider =
    StateProvider<AppSortOrder>((_) => AppSortOrder.alphabeticalAsc);

/// Combines snap and deb updates into a single sorted list of apps with
/// pending updates, used to populate the "Updates" section of the manage page.
@riverpod
Future<List<ManageAppData>> appUpdates(Ref ref) async {
  final snapUpdates = await ref.watch(snapUpdatesModelProvider.future);
  final debUpdates = await ref.watch(debUpdatesModelProvider.future);

  final snapApps = snapUpdates.snaps.map(
    (snap) => ManageAppData.snap(
      snap: snap,
      updateVersion: snap.version,
    ),
  );

  final debApps = debUpdates.map((deb) => ManageAppData.deb(debInfo: deb));

  return [...snapApps, ...debApps]..sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
}

/// Manages the list of installed apps (snaps and debs) that do not have
/// pending updates. Supports filtering by name, toggling system app visibility,
/// sorting, and removing deb packages via PackageKit.
@riverpod
class InstalledApps extends _$InstalledApps {
  /// Unfiltered list of all installed apps. Filtering is applied on top of this.
  late List<ManageAppData> _allApps;
  PackageKitService get _packageKit => getService<PackageKitService>();

  /// Builds the installed apps list by combining local snaps (excluding those
  /// with pending refreshes) and local debs (excluding those with updates).
  /// Registers listeners to re-apply filters when filter/sort state changes.
  @override
  Future<List<ManageAppData>> build() async {
    final snapListState = await ref.watch(localSnapsProvider.future);
    final debs = await ref.watch(localDebsProvider.future);
    final refreshableSnaps = (await ref.read(snapUpdatesModelProvider.future))
        .snaps
        .map((s) => s.name);

    final snapApps = snapListState.snaps
        .where((s) => !refreshableSnaps.contains(s.name))
        .map(
          (snap) => ManageAppData.snap(
            snap: snap,
            updateVersion: ref.watch(updateVersionProvider(snap.name)),
          ),
        );

    final debApps = debs
        .where((deb) => !deb.hasUpdate)
        .map((deb) => ManageAppData.deb(debInfo: deb));

    _allApps = [...snapApps, ...debApps];

    void refreshFunction(_, __) => _applyFilters();
    ref.listen(localSnapFilterProvider, refreshFunction);
    ref.listen(localDebFilterProvider, refreshFunction);
    ref.listen(showLocalSystemAppsProvider, refreshFunction);
    ref.listen(appSortOrderProvider, refreshFunction);

    return _applyFilters(updateState: false);
  }

  /// Filters [_allApps] by search text, system app visibility, and sort order.
  /// When [updateState] is true, also pushes the result to the provider state.
  List<ManageAppData> _applyFilters({bool updateState = true}) {
    final filter = ref.read(localSnapFilterProvider).toLowerCase();
    final showSystemApps = ref.read(showLocalSystemAppsProvider);
    final sortOrder = ref.read(appSortOrderProvider);

    final filtered = _allApps
        .where(
          (app) => filter.isEmpty || app.name.toLowerCase().contains(filter),
        )
        .where((app) => showSystemApps || app.isLaunchable)
        .sortedApps(sortOrder);

    if (updateState) {
      state = AsyncData(filtered);
    }

    return filtered;
  }

  // Deb lifecycle actions (remove, cancel) live here because there is no
  // per-deb notifier equivalent to `SnapModel`. Since `InstalledApps` owns the
  // list that these actions mutate, it also handles the PackageKit transactions.

  /// Removes a deb package via PackageKit, tracks the transaction in state,
  /// and removes the app from the list once the transaction completes.
  Future<void> removeDeb(String debId) async {
    if (!state.hasValue) return;
    final app = _allApps.firstWhere((a) => a.id == debId);
    final debInfo = (app as ManageDebData).debInfo;
    final transactionId =
        await _packageKit.remove(debInfo.packageInfo.packageId);
    log.info('Remove transaction started: $transactionId for $debId');
    _updateDebTransactionId(debId, transactionId);
    await _packageKit.waitTransaction(transactionId);
    log.info('Remove transaction completed: $transactionId for $debId');
    _removeDebFromList(debId);
  }

  /// Cancels an in-progress PackageKit removal transaction for the given deb.
  Future<void> cancelDebTransaction(String debId) async {
    if (!state.hasValue) return;
    final app = _allApps.firstWhere((a) => a.id == debId);
    final debInfo = (app as ManageDebData).debInfo;
    if (debInfo.activeTransactionId == null) return;
    await _packageKit.cancelTransaction(debInfo.activeTransactionId!);
    _updateDebTransactionId(debId, null);
  }

  /// Removes a deb from [_allApps] and re-applies filters.
  void _removeDebFromList(String debId) {
    _allApps = _allApps.where((app) => app.id != debId).toList();
    _applyFilters();
  }

  /// Updates the active transaction ID for a deb in [_allApps] and re-applies
  /// filters, used to track which PackageKit transaction is running.
  void _updateDebTransactionId(String debId, int? transactionId) {
    _allApps = _allApps.map((app) {
      if (app.id == debId && app is ManageDebData) {
        return ManageAppData.deb(
          debInfo: app.debInfo.copyWith(activeTransactionId: transactionId),
        );
      }
      return app;
    }).toList();
    _applyFilters();
  }
}
