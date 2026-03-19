import 'dart:async';

import 'package:app_center/manage/app_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/logger.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_updates_model.g.dart';

/// Tracks the IDs of debs currently being updated by [LocalDebUpdatesModel.updateAll].
/// Empty when no bulk update is in progress.
final currentlyUpdatingAllDebsProvider = StateProvider<List<String>>((_) => []);

/// Tracks whether a silent deb updates check is in progress.
final isSilentlyCheckingDebUpdatesProvider = StateProvider<bool>((_) => false);

/// Provides the progress (0.0 to 1.0) of an active PackageKit transaction.
/// Returns null if no transaction is active or the transaction cannot be found.
final debTransactionProgressProvider =
    StateProvider.family<double?, int?>((ref, transactionId) {
  if (transactionId == null) return null;

  final packageKit = getService<PackageKitService>();
  final transaction = packageKit.getTransaction(transactionId);
  if (transaction == null) return null;

  // Listen to property changes and update progress
  late final StreamSubscription<List<String>> subscription;
  subscription = transaction.propertiesChanged.listen((changedProps) {
    if (changedProps.contains('Percentage')) {
      final percentage = transaction.percentage;
      // PackageKit returns 101 when percentage is unknown
      if (percentage <= 100) {
        ref.controller.state = percentage / 100.0;
      }
    }
  });
  ref.onDispose(subscription.cancel);

  // Return initial progress
  final percentage = transaction.percentage;
  return percentage <= 100 ? percentage / 100.0 : null;
});

/// Manages the list of locally-installed deb packages that have available
/// updates, and exposes actions to update or cancel individual or bulk updates
/// via PackageKit.
@Riverpod(keepAlive: true)
class LocalDebUpdatesModel extends _$LocalDebUpdatesModel {
  late final _packageKit = getService<PackageKitService>();

  /// Builds the initial state by filtering local debs to only those with
  /// pending updates.
  @override
  Future<List<LocalDebInfo>> build() async {
    final debs = await ref.watch(localDebsProvider.future);
    return debs.where((deb) => deb.hasUpdate).toList();
  }

  /// Removes a deb from the update list (e.g. after it has been updated).
  void removeFromList(String debId) {
    if (!state.hasValue) return;
    state = AsyncData(state.value!.where((d) => d.id != debId).toList());
  }

  /// Silently checks for deb updates without invalidating the UI.
  /// Only updates the state if the list of updates has changed.
  Future<void> silentUpdatesCheck() async {
    ref.read(isSilentlyCheckingDebUpdatesProvider.notifier).state = true;
    try {
      final updatesMap = await _packageKit.getUpdates();
      final installed = await ref.read(installedPackagesProvider.future);
      final componentsByPkg =
          await ref.read(componentsByPackageProvider.future);

      // Build map of package name -> update package ID
      final newUpdatesMap = {
        for (final u in updatesMap) u.packageId.name: u.packageId,
      };

      // Filter to packages with Appstream entries that have updates
      final guiPackagesWithUpdates = installed
          .where(
            (pkg) =>
                componentsByPkg.containsKey(pkg.packageId.name) &&
                newUpdatesMap.containsKey(pkg.packageId.name),
          )
          .toList();

      final packageIds =
          guiPackagesWithUpdates.map((p) => p.packageId).toList();
      final details = packageIds.isNotEmpty
          ? await _packageKit.getDetails(packageIds)
          : <String, PackageKitPackageDetails>{};

      final newDebsList = guiPackagesWithUpdates.map((pkg) {
        final name = pkg.packageId.name;
        final component = componentsByPkg[name];
        return LocalDebInfo(
          id: component?.id ?? name,
          packageInfo: pkg,
          component: component,
          details: details[name],
          updatePackageId: newUpdatesMap[name],
        );
      }).toList();

      // Only update if list changed
      final currentIds = state.valueOrNull?.map((d) => d.id).toSet() ?? {};
      final newIds = newDebsList.map((d) => d.id).toSet();
      if (!const SetEquality<String>().equals(currentIds, newIds)) {
        state = AsyncData(newDebsList);
      }
    } finally {
      ref.read(isSilentlyCheckingDebUpdatesProvider.notifier).state = false;
    }
  }

  /// Updates a single deb package by starting a PackageKit transaction,
  /// waiting for it to complete, then moving the deb from the updates list
  /// to the installed apps list.
  Future<void> updateDeb(String debId) async {
    if (!state.hasValue) return;
    final deb = state.value!.firstWhere((d) => d.id == debId);
    if (deb.updatePackageId == null) return;
    final transactionId = await _packageKit.update(deb.updatePackageId!);
    log.info('Update transaction started: $transactionId for $debId');
    _updateTransactionId(debId, transactionId);
    try {
      await _packageKit.waitTransaction(transactionId);
      log.info('Update transaction completed: $transactionId for $debId');
      removeFromList(debId);
      // Add the updated deb to the installed apps list (with update cleared)
      final updatedDeb = deb.copyWith(
        updatePackageId: null,
        activeTransactionId: null,
      );
      ref.read(installedAppsProvider.notifier).addDebToList(updatedDeb);
    } finally {
      // Always clear the transaction state, even if cancelled or failed
      _updateTransactionId(debId, null);
    }
  }

  /// Cancels an in-progress PackageKit transaction for the given deb.
  Future<void> cancelTransaction(String debId) async {
    if (!state.hasValue) return;
    final deb = state.value!.where((d) => d.id == debId).firstOrNull;
    if (deb?.activeTransactionId == null) return;
    await _packageKit.cancelTransaction(deb!.activeTransactionId!);
    _updateTransactionId(debId, null);
  }

  /// Updates all debs with pending updates sequentially. Collects any errors
  /// per-deb and reports them to the error stream after all updates complete.
  Future<void> updateAll() async {
    if (!state.hasValue) return;
    final debIds =
        state.value!.where((d) => d.hasUpdate).map((d) => d.id).toList();
    if (debIds.isEmpty) return;

    final errors = <String, Exception>{};
    try {
      ref.read(currentlyUpdatingAllDebsProvider.notifier).state = debIds;

      for (final debId in debIds) {
        try {
          await updateDeb(debId);
        } on Exception catch (e) {
          errors[debId] = e;
        }
      }
    } finally {
      ref.read(currentlyUpdatingAllDebsProvider.notifier).state = [];
      if (errors.isNotEmpty) {
        for (final error in errors.values) {
          ref.read(errorStreamControllerProvider).add(error);
        }
      }
      ref.invalidateSelf();
      ref.invalidate(localDebsProvider);
    }
  }

  /// Cancels all in-progress transactions for the current bulk update.
  /// Logs warnings for any cancellations that fail.
  Future<void> cancelAll() async {
    final debIds = ref.read(currentlyUpdatingAllDebsProvider);
    if (debIds.isEmpty) return;

    try {
      for (final debId in debIds) {
        try {
          await cancelTransaction(debId);
        } on Exception catch (e) {
          log.warning('Failed to cancel transaction for $debId: $e');
        }
      }
    } finally {
      ref.read(currentlyUpdatingAllDebsProvider.notifier).state = [];
    }
  }

  /// Updates the active transaction ID for a deb in the current state,
  /// used to track which PackageKit transaction is running for a given deb.
  void _updateTransactionId(String debId, int? transactionId) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.map((d) {
        if (d.id == debId) {
          return d.copyWith(activeTransactionId: transactionId);
        }
        return d;
      }).toList(),
    );
  }
}
