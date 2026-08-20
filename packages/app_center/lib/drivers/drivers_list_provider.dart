import 'package:app_center/drivers/drivers_data.dart';
import 'package:app_center/drivers/drivers_model.dart';
import 'package:app_center/drivers/drivers_service.dart';
import 'package:app_center/drivers/logger.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'drivers_list_provider.g.dart';

/// Fetches the detected hardware devices and their candidate driver
/// packages, enriched with PackageKit install/update state.
///
/// Read-only: holds no transaction state. Per-device mutable state lives on
/// the driver model provider instead.
@Riverpod(keepAlive: true)
class DriverListModel extends _$DriverListModel {
  @override
  Future<DriverList> build() async {
    final driversService = getService<DriversService>();
    final packageKit = getService<PackageKitService>();

    await packageKit.activateService();

    final devices = await driversService.getDrivers();

    final filtered = <DriverDevice>[];
    for (final device in devices) {
      if (device.sysPath.isEmpty) {
        log.warning(
          'Dropping a driver device with no sys_path '
          '(vendor: ${device.vendor}, model: ${device.model})',
        );
        continue;
      }
      // Builtin candidates (e.g. nouveau) are a fallback, not installable.
      final candidates = device.drivers.where((d) => !d.builtin).toList();
      if (candidates.isEmpty) continue;
      filtered.add(device.copyWith(drivers: candidates));
    }

    final allPackageNames = filtered
        .expand((device) => device.drivers.map((d) => d.name))
        .toSet()
        .toList();

    final resolved = await packageKit.resolve(allPackageNames);
    final updates = await packageKit.getUpdates();
    final updatedPackageNames = updates.map((u) => u.packageId.name).toSet();

    final byPath = <String, DriverDeviceInfo>{};
    final sysPaths = <String>[];
    for (final device in filtered) {
      final options = device.drivers.map((driver) {
        final packageInfo = resolved[driver.name];
        final isInstalled = packageInfo?.info == PackageKitInfo.installed;
        return DriverBranchOption(
          branch: DriverBranch.fromSupport(driver.support),
          packageName: driver.name,
          recommended: driver.recommended,
          packageId: packageInfo?.packageId,
          isInstalled: isInstalled,
          hasUpdate: isInstalled && updatedPackageNames.contains(driver.name),
        );
      }).toList();

      byPath[device.sysPath] = DriverDeviceInfo(
        sysPath: device.sysPath,
        vendor: device.vendor,
        model: device.model,
        deviceClass: DriverDeviceClass.fromModalias(device.modalias),
        options: options,
      );
      sysPaths.add(device.sysPath);
    }

    return DriverList(byPath: byPath, sysPaths: sysPaths);
  }

  /// Re-fetches devices and their driver state from scratch.
  void refresh() => ref.invalidateSelf();
}
