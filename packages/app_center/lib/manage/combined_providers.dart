import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/manage/deb_updates_provider.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/manage_filters.dart';
import 'package:app_center/manage/snap_updates_provider.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';

part 'combined_providers.g.dart';

/// Returns combined updates from both snaps and debs.
@Riverpod(keepAlive: true)
class CombinedUpdates extends _$CombinedUpdates {
  @override
  Future<List<ManageAppData>> build() async {
    // Load both snap and deb updates - await both to avoid partial UI states
    final snapUpdates = await ref.watch(snapUpdatesProvider.future);
    final debUpdates = await ref.watch(debUpdatesProvider.future);

    // Get the local snaps to retrieve installed versions for display
    final localSnaps = await ref.watch(localSnapsProvider.future);

    final combined = <ManageAppData>[
      ...snapUpdates.snaps.map((storeSnap) {
        final localSnap = localSnaps.snaps
            .where((s) => s.name == storeSnap.name)
            .firstOrNull;
        return ManageSnapData(
          snap: localSnap ?? storeSnap,
          hasUpdate: true,
          updateVersion: storeSnap.version,
        );
      }),
      ...debUpdates,
    ];

    combined.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return combined;
  }

  Future<void> refreshAll() async {
    final errors = <String, Exception>{};
    try {
      // Update snaps
      final snapUpdates = ref.read(snapUpdatesProvider);
      if (snapUpdates.hasValue) {
        final refreshableSnapNames = snapUpdates.value?.snaps
                .where((s) => s.refreshInhibit == null)
                .map((s) => s.name)
                .toList() ??
            [];
        if (refreshableSnapNames.isNotEmpty) {
          ref.read(currentlyRefreshAllSnapsProvider.notifier).state =
              refreshableSnapNames.toList();

          Future<void> refreshSnap(String snapName) async {
            final refreshFuture =
                ref.read(SnapModelProvider(snapName).notifier).refresh();
            try {
              final completedSuccessfully = await refreshFuture;
              if (completedSuccessfully) {
                ref
                    .read(snapUpdatesProvider.notifier)
                    .removeFromList(snapName);
              }
            } on Exception catch (e) {
              if (e is SnapdException && e.kind == 'auth-cancelled') {
                rethrow;
              }
              errors[snapName] = e;
            }
          }

          // Refresh the first snap first so that we only ask for the password once.
          final firstSnap = refreshableSnapNames.removeAt(0);
          await refreshSnap(firstSnap);

          final refreshFutures = refreshableSnapNames.map(refreshSnap);
          await Future.wait(refreshFutures);
        }
      }

      // Update debs
      final debUpdates = ref.read(debUpdatesProvider).valueOrNull ?? [];
      for (final deb in debUpdates) {
        if (deb.updatePackageId != null) {
          try {
            await ref
                .read(debModelProvider(deb.id).notifier)
                .updateDeb(deb.updatePackageId!);
          } on Exception catch (e) {
            errors[deb.name] = e;
          }
        }
      }
    } on SnapdException catch (e) {
      if (e.kind != 'auth-cancelled') {
        ref.read(errorStreamControllerProvider).add(e);
      }
    } finally {
      ref.read(currentlyRefreshAllSnapsProvider.notifier).state = [];
      if (errors.isNotEmpty) {
        ref.read(errorStreamControllerProvider).add(
              errors.length == 1
                  ? errors.values.first
                  : ConsolidatedSnapdException(errors),
            );
      }
      ref.invalidate(snapUpdatesProvider);
      ref.invalidate(localSnapsProvider);
    }
  }

  Future<void> cancelRefreshAll() async {
    final snapNames = ref.read(currentlyRefreshAllSnapsProvider);
    if (snapNames.isEmpty) return;

    try {
      final cancelFutures = snapNames.map(
        (snapName) => ref.read(SnapModelProvider(snapName).notifier).cancel(),
      );
      await Future.wait(cancelFutures);
    } on SnapdException catch (e) {
      ref.read(errorStreamControllerProvider).add(e);
    } finally {
      ref.read(currentlyRefreshAllSnapsProvider.notifier).state = [];
    }
  }
}

/// Returns whether there's internet connectivity for updates.
@riverpod
bool combinedHasInternet(Ref ref) {
  final snapUpdates = ref.watch(snapUpdatesProvider);
  return snapUpdates.valueOrNull?.hasInternet ?? true;
}

/// Returns combined installed apps from both snaps and debs.
@riverpod
class CombinedInstalled extends _$CombinedInstalled {
  @override
  Future<List<ManageAppData>> build() async {
    final localSnaps = await ref.watch(localSnapsProvider.future);
    final installedDebs = await ref.watch(installedDebsProvider.future);
    final debUpdates = ref.watch(debUpdatesProvider).valueOrNull ?? [];

    final filter = ref.watch(appFilterProvider).toLowerCase();
    final showSystemApps = ref.watch(showSystemAppsProvider);
    final sortOrder = ref.watch(appSortOrderProvider);
    final packageTypeFilter = ref.watch(packageTypeFilterProvider);

    // Convert snaps to ManageSnapData
    final snapApps = localSnaps.snaps.map(
      (snap) => ManageSnapData(
        snap: snap,
        hasUpdate: ref.watch(snapHasUpdateProvider(snap.name)),
        updateVersion: ref.watch(snapUpdateVersionProvider(snap.name)),
      ),
    );

    // Merge deb update info into installed debs
    final debApps = installedDebs.map((deb) {
      final update = debUpdates.where((d) => d.id == deb.id).firstOrNull;
      return update ?? deb;
    });

    // Apply package type filter
    final combined = <ManageAppData>[
      if (packageTypeFilter != PackageTypeFilter.deb) ...snapApps,
      if (packageTypeFilter != PackageTypeFilter.snap) ...debApps,
    ];

    // Apply filters
    final filtered = combined
        .where((app) => !app.hasUpdate) // Exclude apps with pending updates
        .where((app) => app.name.toLowerCase().contains(filter))
        .where((app) => showSystemApps || app.isLaunchable)
        .toList();

    // Apply sorting
    return filtered.sortedApps(sortOrder);
  }
}
