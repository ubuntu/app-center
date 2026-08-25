import 'package:app_center/drivers/drivers_busy_provider.dart';
import 'package:app_center/drivers/drivers_data.dart';
import 'package:app_center/drivers/drivers_list_provider.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

/// The kind of PackageKit transaction currently in progress for a device,
/// used to pick the right busy label in the UI.
enum DriverActionKind { install, update, uninstall, switchBranch }

/// Per-device mutable state not covered by [DriverDeviceInfo]: transaction,
/// error, and restart-required status.
@freezed
class DriverDeviceState with _$DriverDeviceState {
  const factory DriverDeviceState({
    required DriverDeviceInfo info,
    int? activeTransactionId,
    DriverActionKind? activeActionKind,
    PackageKitServiceError? error,
    @Default(false) bool requiresRestart,
  }) = _DriverDeviceState;

  const DriverDeviceState._();

  bool get isBusy => activeTransactionId != null;
}

/// Owns install/update/uninstall/switch-branch/cancel state for a single
/// device, identified by its `sysPath`. Facts come from [driverListModelProvider]
/// via a narrowed selector; this notifier only adds transient per-device
/// state.
@riverpod
class DriverModel extends _$DriverModel {
  late final _packageKit = getService<PackageKitService>();

  @override
  Future<DriverDeviceState> build(String sysPath) async {
    final info = await ref.watch(
      driverListModelProvider.selectAsync((list) => list.byPath[sysPath]),
    );
    if (info == null) {
      throw StateError('No driver device found for sysPath: $sysPath');
    }
    // Carry forward transient state across rebuilds triggered by
    // driverListModelProvider refreshing.
    final previous = state.valueOrNull;
    return DriverDeviceState(
      info: info,
      activeTransactionId: previous?.activeTransactionId,
      activeActionKind: previous?.activeActionKind,
      error: previous?.error,
      requiresRestart: previous?.requiresRestart ?? false,
    );
  }

  /// Whether this device can start a new operation: no transaction already
  /// running here, and no other device transacting (see [driversBusyProvider]).
  bool get canOperate {
    final current = state.valueOrNull;
    if (current == null || current.isBusy) return false;
    return !ref.read(driversBusyProvider);
  }

  /// Installs [packageName] for this device, e.g. when no branch is
  /// currently installed yet.
  Future<void> install(String packageName) => _driverAction(
    DriverActionKind.install,
    () => _packageKit.install(_packageIdFor(packageName)),
  );

  /// Switches the currently-installed candidate to a different branch's
  /// [packageName]: installing a different candidate relies on apt/dpkg
  /// conflict resolution to remove the previously-installed candidate
  /// atomically.
  ///
  /// OPEN ITEM (unverified on real hardware): if the aptcc PackageKit backend
  /// refuses a single-transaction switch requiring a removal, this needs to
  /// fall back to install-then-remove as two transactions - never
  /// remove-then-install.
  Future<void> switchBranch(String packageName) => _driverAction(
    DriverActionKind.switchBranch,
    () => _packageKit.install(_packageIdFor(packageName)),
  );

  /// Updates the currently-installed candidate to its available update.
  Future<void> updateDriver() {
    final installed = state.value?.info.installedOption;
    assert(installed?.packageId != null);
    return _driverAction(
      DriverActionKind.update,
      () => _packageKit.update(installed!.packageId!),
    );
  }

  /// Uninstalls the currently-installed candidate.
  ///
  /// TODO: only removes the metapackage, not dependencies (e.g.
  /// nvidia-kernel-common-*, DKMS modules). Same open question as
  /// PackageKitService.remove.
  Future<void> uninstall() {
    final installed = state.value?.info.installedOption;
    assert(installed?.packageId != null);
    return _driverAction(
      DriverActionKind.uninstall,
      () => _packageKit.remove(installed!.packageId!),
    );
  }

  /// Best-effort cancellation. If PackageKit refuses, the transaction
  /// continues and this is a no-op.
  Future<void> cancel() async {
    final transactionId = state.valueOrNull?.activeTransactionId;
    if (transactionId == null) return;
    try {
      await _packageKit.cancelTransaction(transactionId);
    } on Exception catch (_) {
      // Refused; transaction keeps running.
    }
  }

  PackageKitPackageId _packageIdFor(String packageName) {
    final option = state.value!.info.options.firstWhere(
      (o) => o.packageName == packageName,
      orElse: () => throw StateError(
        'Unknown driver package $packageName for device $sysPath',
      ),
    );
    return option.packageId ??
        PackageKitPackageId(name: packageName, version: '');
  }

  Future<void> _driverAction(
    DriverActionKind kind,
    Future<int> Function() action,
  ) async {
    if (!canOperate) {
      throw StateError(
        'Cannot start a driver operation for $sysPath: another operation is '
        'already in progress.',
      );
    }
    // Set synchronously, before any `await`, so a racing call can't also
    // observe `canOperate` as true.
    ref.read(driversBusyProvider.notifier).state = true;
    final keepAliveLink = ref.keepAlive();
    try {
      final transactionId = await action();
      state = AsyncData(
        state.value!.copyWith(
          activeTransactionId: transactionId,
          activeActionKind: kind,
          error: null,
        ),
      );

      try {
        await _packageKit.waitTransaction(transactionId);
        final requiresRestart = _packageKit.requiresRestartFor(transactionId);
        state = AsyncData(
          state.value!.copyWith(
            activeTransactionId: null,
            activeActionKind: null,
            requiresRestart: requiresRestart,
          ),
        );
        ref.invalidate(driverListModelProvider);
      } on PackageKitTransactionError catch (e) {
        if (e.exit == PackageKitExit.cancelled) {
          state = AsyncData(
            state.value!.copyWith(
              activeTransactionId: null,
              activeActionKind: null,
            ),
          );
        } else {
          state = AsyncData(
            state.value!.copyWith(
              activeTransactionId: null,
              activeActionKind: null,
              error: _packageKit.lastErrorFor(transactionId),
            ),
          );
        }
      }
    } finally {
      ref.read(driversBusyProvider.notifier).state = false;
      keepAliveLink.close();
    }
  }
}
