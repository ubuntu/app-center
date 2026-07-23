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

  /// Whether the `com.ubuntu.Drivers` service could be reached.
  bool get isAvailable => _isAvailable;
  bool _isAvailable = false;

  /// Explicitly activates the drivers service in case it is not running.
  Future<void> activateService() async {
    if (_isAvailable) return;

    final object = DBusRemoteObject(
      _dbus,
      name: 'org.freedesktop.DBus',
      path: DBusObjectPath('/org/freedesktop/DBus'),
    );
    try {
      await object.callMethod(
        'org.freedesktop.DBus',
        'StartServiceByName',
        [DBusString(_serviceName), const DBusUint32(0)],
      );
      _isAvailable = true;
    } on DBusServiceUnknownException catch (_) {
      log.info(
        'Could not connect to $_serviceName - marking service as unavailable',
      );
    } on DBusMethodResponseException catch (e) {
      log.info(
        'Could not start $_serviceName ($e) - marking service as unavailable',
      );
    }
  }

  /// Returns the detected devices and their driver packages.
  ///
  /// Returns an empty list if the service is unavailable (see [isAvailable]).
  ///
  /// The `com.ubuntu.Drivers` service exits after a period of inactivity, so
  /// [isAvailable] being `true` does not guarantee the service is still
  /// running. If a call finds the service gone (`ServiceUnknown`),
  /// [isAvailable] is reset to `false` and reactivation is retried once
  /// before falling back to an empty list.
  ///
  /// Throws [DriversServiceException] if the service reports an error while
  /// building the driver list.
  Future<List<DriverDevice>> getDrivers() async {
    if (!_isAvailable) {
      await activateService();
    }
    if (!_isAvailable) {
      return const [];
    }

    try {
      return await _callDrivers();
    } on DBusServiceUnknownException catch (_) {
      log.info(
        '$_serviceName is no longer reachable (likely an idle timeout) - '
        'attempting to reactivate',
      );
      _isAvailable = false;
      await activateService();
      if (!_isAvailable) {
        return const [];
      }
      return _callDrivers();
    }
  }

  Future<List<DriverDevice>> _callDrivers() async {
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
    } on DBusServiceUnknownException {
      rethrow;
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
