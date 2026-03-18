import 'package:app_center/manage/app_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/logger.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'deb_updates_model.g.dart';

/// Tracks the IDs of debs currently being updated by [DebUpdatesModel.updateAll].
/// Empty when no bulk update is in progress.
final currentlyUpdatingAllDebsProvider = StateProvider<List<String>>((_) => []);

/// Manages the list of locally-installed deb packages that have available
/// updates, and exposes actions to update or cancel individual or bulk updates
/// via PackageKit.
@Riverpod(keepAlive: true)
class DebUpdatesModel extends _$DebUpdatesModel {
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
    await _packageKit.waitTransaction(transactionId);
    log.info('Update transaction completed: $transactionId for $debId');
    _updateTransactionId(debId, null);
    removeFromList(debId);
    // Add the updated deb to the installed apps list (with update cleared)
    final updatedDeb = deb.copyWith(
      updatePackageId: null,
      activeTransactionId: null,
    );
    ref.read(installedAppsProvider.notifier).addDebToList(updatedDeb);
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
