import 'package:app_center/drivers/drivers_model.dart';
import 'package:app_center/drivers/drivers_service.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'drivers_service_test.mocks.dart';

const _driversDBusName = 'com.ubuntu.Drivers';
const _driversDBusObjectPath = '/com/ubuntu/Drivers';

/// The `drivers` call `DriversService.getDrivers` makes.
Future<DBusMethodSuccessResponse> _driversCall(MockDBusClient dbus) =>
    dbus.callMethod(
      path: DBusObjectPath(_driversDBusObjectPath),
      destination: _driversDBusName,
      name: 'drivers',
      interface: _driversDBusName,
      replySignature: DBusSignature('aa{sv}'),
    );

void main() {
  group('getDrivers', () {
    test('returns an empty list if the service is unreachable', () async {
      final dbus = createMockDbusClient();
      when(_driversCall(dbus)).thenThrow(
        DBusServiceUnknownException(
          DBusMethodErrorResponse('org.freedesktop.DBus.Error.ServiceUnknown'),
        ),
      );

      final drivers = DriversService(dbus: dbus);
      final result = await drivers.getDrivers();
      expect(result, isEmpty);
    });

    test('parses devices and driver packages', () async {
      final dbus = createMockDbusClient();
      when(_driversCall(dbus)).thenAnswer(
        (_) async => DBusMethodSuccessResponse([_nvidiaDeviceArray]),
      );

      final drivers = DriversService(dbus: dbus);
      final devices = await drivers.getDrivers();

      expect(devices, hasLength(1));
      final device = devices.single;
      expect(device.sysPath, equals('/sys/devices/pci0000:00/0000:01:00.0'));
      expect(
        device.modalias,
        equals(
          'pci:v000010DEd000010C3sv00003842sd00002670bc03sc03i00',
        ),
      );
      expect(device.vendor, equals('NVIDIA Corporation'));
      expect(device.model, equals('GK208 [GeForce GT 720]'));
      expect(device.drivers, hasLength(5));

      final recommended = device.drivers[0];
      expect(recommended.name, equals('nvidia-driver-450'));
      expect(recommended.source, equals(DriverSource.distro));
      expect(recommended.free, isFalse);
      expect(recommended.builtin, isFalse);
      expect(recommended.recommended, isTrue);
      expect(recommended.support, equals('PB'));

      DriverPackage byName(String name) =>
          device.drivers.firstWhere((d) => d.name == name);

      expect(byName('nvidia-driver-550').support, equals('NFB'));
      expect(byName('nvidia-driver-470').support, equals('LTSB'));
      expect(byName('nvidia-driver-390').support, equals('Legacy'));

      final nouveau = byName('xserver-xorg-video-nouveau');
      expect(nouveau.free, isTrue);
      expect(nouveau.builtin, isTrue);
      expect(nouveau.recommended, isFalse);
      // No Support header in the package's apt metadata.
      expect(nouveau.support, isEmpty);
    });

    test('missing keys fall back to safe defaults', () async {
      final dbus = createMockDbusClient();
      final emptyDevice = DBusDict.stringVariant({
        'sys_path': const DBusString('/sys/devices/pci0000:00/0000:02:00.0'),
      });
      when(_driversCall(dbus)).thenAnswer(
        (_) async => DBusMethodSuccessResponse([
          DBusArray(DBusSignature('a{sv}'), [emptyDevice]),
        ]),
      );

      final drivers = DriversService(dbus: dbus);
      final devices = await drivers.getDrivers();

      expect(devices, hasLength(1));
      final device = devices.single;
      expect(device.modalias, isEmpty);
      expect(device.vendor, isEmpty);
      expect(device.model, isEmpty);
      expect(device.drivers, isEmpty);
    });

    test('empty result', () async {
      final dbus = createMockDbusClient();
      when(_driversCall(dbus)).thenAnswer(
        (_) async => DBusMethodSuccessResponse([
          DBusArray(DBusSignature('a{sv}')),
        ]),
      );

      final drivers = DriversService(dbus: dbus);
      final devices = await drivers.getDrivers();
      expect(devices, isEmpty);
    });

    test('cache failure throws DriversServiceException', () async {
      final dbus = createMockDbusClient();
      when(_driversCall(dbus)).thenThrow(
        DBusMethodResponseException(
          DBusMethodErrorResponse('com.ubuntu.Drivers.Error.CacheFailure'),
        ),
      );

      final drivers = DriversService(dbus: dbus);
      expect(drivers.getDrivers(), throwsA(isA<DriversServiceException>()));
    });
  });
}

DBusDict _driverPackage({
  required String name,
  required String source,
  required bool free,
  required bool builtin,
  required bool recommended,
  required String support,
}) {
  return DBusDict.stringVariant({
    'name': DBusString(name),
    'source': DBusString(source),
    'free': DBusBoolean(free),
    'builtin': DBusBoolean(builtin),
    'recommended': DBusBoolean(recommended),
    'support': DBusString(support),
  });
}

final _nvidiaDeviceArray = DBusArray(DBusSignature('a{sv}'), [
  DBusDict.stringVariant({
    'sys_path': const DBusString('/sys/devices/pci0000:00/0000:01:00.0'),
    'modalias': const DBusString(
      'pci:v000010DEd000010C3sv00003842sd00002670bc03sc03i00',
    ),
    'vendor': const DBusString('NVIDIA Corporation'),
    'model': const DBusString('GK208 [GeForce GT 720]'),
    'drivers': DBusArray(DBusSignature('v'), [
      DBusVariant(
        _driverPackage(
          name: 'nvidia-driver-450',
          source: 'distro',
          free: false,
          builtin: false,
          recommended: true,
          support: 'PB',
        ),
      ),
      DBusVariant(
        _driverPackage(
          name: 'nvidia-driver-550',
          source: 'distro',
          free: false,
          builtin: false,
          recommended: false,
          support: 'NFB',
        ),
      ),
      DBusVariant(
        _driverPackage(
          name: 'nvidia-driver-470',
          source: 'distro',
          free: false,
          builtin: false,
          recommended: false,
          support: 'LTSB',
        ),
      ),
      DBusVariant(
        _driverPackage(
          name: 'nvidia-driver-390',
          source: 'distro',
          free: false,
          builtin: false,
          recommended: false,
          support: 'Legacy',
        ),
      ),
      DBusVariant(
        _driverPackage(
          name: 'xserver-xorg-video-nouveau',
          source: 'distro',
          free: true,
          builtin: true,
          recommended: false,
          support: '',
        ),
      ),
    ]),
  }),
]);

@GenerateMocks([DBusClient])
MockDBusClient createMockDbusClient() => MockDBusClient();
