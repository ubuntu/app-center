import 'package:app_center/drivers/drivers_model.dart';
import 'package:app_center/drivers/drivers_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'drivers_provider.g.dart';

/// The list of detected devices and their available driver packages, as
/// reported by the `com.ubuntu.Drivers` D-Bus service.
///
/// Returns an empty list if the service is unavailable.
@riverpod
Future<List<DriverDevice>> drivers(Ref ref) async {
  final drivers = getService<DriversService>();
  return drivers.getDrivers();
}

/// Determine whether the drivers D-Bus service is available.
@riverpod
Future<bool> driversAvailable(Ref ref) async {
  final drivers = getService<DriversService>();
  return drivers.isAvailable;
}
