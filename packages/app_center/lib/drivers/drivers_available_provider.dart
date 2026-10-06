import 'package:app_center/drivers/drivers_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'drivers_available_provider.g.dart';

/// Whether the `com.ubuntu.Drivers` D-Bus service is reachable.
///
/// While resolving (or if it errors), treated as unavailable so that
/// dependent UI (the Add-ons tab, the drivers tile) stays hidden until
/// proven reachable rather than flashing on then off.
@Riverpod(keepAlive: true)
Future<bool> driversAvailable(Ref ref) =>
    getService<DriversService>().isAvailable();
