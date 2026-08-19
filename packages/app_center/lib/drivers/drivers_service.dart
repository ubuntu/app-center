import 'package:app_center/drivers/drivers_model.dart';
import 'package:app_center/drivers/logger.dart';
import 'package:dbus/dbus.dart';

class DriversServiceException implements Exception {
  DriversServiceException(this.message);
  final String message;

  @override
  String toString() => 'DriversServiceException: $message';
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
  /// Returns an empty list if the service is unreachable.
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
      log.info('Could not reach $_serviceName - returning an empty list');
      return const [];
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
      sysPath: _asString(fields['sys_path']),
      modalias: _asString(fields['modalias']),
      vendor: _asString(fields['vendor']),
      model: _asString(fields['model']),
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
      name: _asString(fields['name']),
      source: DriverSource.fromString(_asString(fields['source'])),
      free: _asBool(fields['free']),
      builtin: _asBool(fields['builtin']),
      recommended: _asBool(fields['recommended']),
      support: _asString(fields['support']),
    );
  }

  String _asString(DBusValue? value) => value is DBusString ? value.value : '';

  bool _asBool(DBusValue? value) => value is DBusBoolean ? value.value : false;

  /// Closes the underlying D-Bus connection.
  Future<void> dispose() => _dbus.close();
}
