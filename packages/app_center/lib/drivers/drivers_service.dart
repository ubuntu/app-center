import 'package:app_center/drivers/drivers_model.dart';
import 'package:app_center/drivers/logger.dart';
import 'package:dbus/dbus.dart';

class DriversServiceException implements Exception {
  DriversServiceException(this.message);
  final String message;

  @override
  String toString() => 'DriversServiceException: $message';
}

/// Thrown by [DriversService.getDrivers] when the `com.ubuntu.Drivers`
/// D-Bus service can't be reached at all, as opposed to it reporting no
/// devices. This typically means the installed snapd doesn't ship driver
/// management support yet.
class DriversServiceUnavailableException implements Exception {
  @override
  String toString() => 'DriversServiceUnavailableException';
}

const _serviceName = 'com.ubuntu.Drivers';
final _objectPath = DBusObjectPath('/com/ubuntu/Drivers');

/// Client for the `com.ubuntu.Drivers` D-Bus service, which surfaces the
/// hardware devices detected on the system and the driver packages
/// available for each of them.
class DriversService {
  DriversService({DBusClient? dbus}) : _dbus = dbus ?? DBusClient.system();

  final DBusClient _dbus;

  /// Returns the detected devices and their driver packages.
  ///
  /// Throws [DriversServiceUnavailableException] if the service can't be
  /// reached at all (e.g. an older snapd without driver management support).
  ///
  /// Throws [DriversServiceException] if the service reports an error while
  /// building the driver list.
  Future<List<DriverDevice>> getDrivers() async {
    final object = DBusRemoteObject(
      _dbus,
      name: _serviceName,
      path: _objectPath,
    );

    final DBusMethodSuccessResponse response;
    try {
      response = await object.callMethod(
        _serviceName,
        'drivers',
        const [],
        replySignature: DBusSignature('aa{sv}'),
      );
    } on DBusServiceUnknownException catch (_) {
      log.info('Could not reach $_serviceName');
      throw DriversServiceUnavailableException();
    } on DBusMethodResponseException catch (e) {
      throw DriversServiceException(e.toString());
    }

    final devices = response.returnValues.single as DBusArray;
    return devices.children
        .map((device) => _parseDevice(device as DBusDict))
        .toList();
  }

  DriverDevice _parseDevice(DBusDict device) {
    final fields = device.mapStringVariant();
    final driversArray = fields['drivers'] as DBusArray?;

    return DriverDevice(
      sysPath: fields['sys_path']!.asString(),
      modalias: fields['modalias']!.asString(),
      vendor: fields['vendor']!.asString(),
      model: fields['model']!.asString(),
      drivers:
          driversArray?.children
              .map(
                (driver) => _parseDriverPackage(driver.asVariant() as DBusDict),
              )
              .toList() ??
          const [],
    );
  }

  DriverPackage _parseDriverPackage(DBusDict driver) {
    final fields = driver.mapStringVariant();

    return DriverPackage(
      name: fields['name']!.asString(),
      source: DriverSource.fromString(fields['source']!.asString()),
      free: fields['free']!.asBoolean(),
      builtin: fields['builtin']!.asBoolean(),
      recommended: fields['recommended']!.asBoolean(),
      support: fields['support']!.asString(),
      openPreferred: fields['open_preferred']!.asBoolean(),
      packages: fields['packages']!.asStringArray().toList(),
    );
  }

  /// Closes the underlying D-Bus connection.
  Future<void> dispose() => _dbus.close();
}
