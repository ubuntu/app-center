import 'dart:async';

import 'package:app_center/src/packagekit/packagekit_service.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';

import 'packagekit_service_test.mocks.dart';
import 'test_utils.dart';

const _dBusName = 'org.freedesktop.DBus';
const _dBusInterface = 'org.freedesktop.DBus';
const _dBusObjectPath = '/org/freedesktop/DBus';
const _packageKitDBusName = 'org.freedesktop.PackageKit';

void main() {
  group('activate service', () {
    test('service available', () async {
      final dbus = createMockDbusClient();
      final packageKit =
          PackageKitService(dbus: dbus, client: createMockPackageKitClient());
      expect(packageKit.isAvailable, isFalse);
      await packageKit.activateService();
      verify(dbus.callMethod(
        path: DBusObjectPath(_dBusObjectPath),
        destination: _dBusName,
        name: 'StartServiceByName',
        interface: _dBusInterface,
        values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
      )).called(1);
      expect(packageKit.isAvailable, isTrue);

      await packageKit.activateService();
      verifyNever(dbus.callMethod(
        path: DBusObjectPath(_dBusObjectPath),
        destination: _dBusName,
        name: 'StartServiceByName',
        interface: _dBusInterface,
        values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
      ));
    });

    test('service unavailable', () async {
      final dbus = createMockDbusClient();
      final client = createMockPackageKitClient();
      when(client.connect()).thenThrow(
        DBusServiceUnknownException(
          DBusMethodErrorResponse('org.freedesktop.DBus.Error.ServiceUnknown'),
        ),
      );
      final packageKit = PackageKitService(dbus: dbus, client: client);
      expect(packageKit.isAvailable, isFalse);
      await packageKit.activateService();
      verify(dbus.callMethod(
        path: DBusObjectPath(_dBusObjectPath),
        destination: _dBusName,
        name: 'StartServiceByName',
        interface: _dBusInterface,
        values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
      )).called(1);
      expect(packageKit.isAvailable, isFalse);
    });
  });

  test('install', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit =
        PackageKitService(dbus: createMockDbusClient(), client: mockClient);
    await packageKit.activateService();
    final id = await packageKit
        .install(const PackageKitPackageId(name: 'foo', version: '1.0'));
    verify(mockTransaction.installPackages(
        [const PackageKitPackageId(name: 'foo', version: '1.0')])).called(1);
    final transaction = packageKit.getTransaction(id);
    expect(transaction, isNotNull);
    completer.complete();
    await packageKit.waitTransaction(id);
    expect(packageKit.getTransaction(id), isNull);
  });

  test('remove', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit =
        PackageKitService(dbus: createMockDbusClient(), client: mockClient);
    await packageKit.activateService();
    final id = await packageKit
        .remove(const PackageKitPackageId(name: 'foo', version: '1.0'));
    verify(mockTransaction.removePackages(
        [const PackageKitPackageId(name: 'foo', version: '1.0')])).called(1);
    final transaction = packageKit.getTransaction(id);
    expect(transaction, isNotNull);
    completer.complete();
    await packageKit.waitTransaction(id);
    expect(packageKit.getTransaction(id), isNull);
  });

  test('resolve', () async {
    const mockInfo = PackageKitPackageEvent(
      info: PackageKitInfo.available,
      packageId: PackageKitPackageId(name: 'foo', version: '1.0'),
      summary: 'summary',
    );
    final mockTransaction = createMockPackageKitTransaction(
      events: [mockInfo],
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit =
        PackageKitService(dbus: createMockDbusClient(), client: mockClient);
    await packageKit.activateService();
    final info = await packageKit.resolve('foo');
    verify(mockTransaction.resolve(['foo'])).called(1);
    expect(info, equals(mockInfo));
  });

  test('cancel', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit =
        PackageKitService(dbus: createMockDbusClient(), client: mockClient);
    await packageKit.activateService();
    final id = await packageKit
        .install(const PackageKitPackageId(name: 'foo', version: '1.0'));
    verify(mockTransaction.installPackages(
        [const PackageKitPackageId(name: 'foo', version: '1.0')])).called(1);
    final transaction = packageKit.getTransaction(id);
    expect(transaction, isNotNull);
    await packageKit.cancelTransaction(id);
    verify(mockTransaction.cancel()).called(1);
    completer.complete();
    await packageKit.waitTransaction(id);
    expect(packageKit.getTransaction(id), isNull);
  });
}

@GenerateMocks([DBusClient])
MockDBusClient createMockDbusClient() {
  final dbus = MockDBusClient();
  when(dbus.callMethod(
    path: DBusObjectPath(_dBusObjectPath),
    destination: _dBusName,
    name: 'StartServiceByName',
    interface: _dBusInterface,
    values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
  )).thenAnswer((_) async => DBusMethodSuccessResponse());
  return dbus;
}
