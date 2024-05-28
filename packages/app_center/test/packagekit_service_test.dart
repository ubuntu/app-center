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

  test('install local package', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit =
        PackageKitService(dbus: createMockDbusClient(), client: mockClient);
    await packageKit.activateService();
    final id = await packageKit.installLocal('/path/to/local.deb');
    verify(mockTransaction.installFiles(['/path/to/local.deb'])).called(1);
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

  group('resolve', () {
    test('unique package', () async {
      const mockInfo = PackageKitPackageEvent(
        info: PackageKitInfo.available,
        packageId: PackageKitPackageId(
          name: 'foo',
          version: '1.0',
          arch: 'amd64',
        ),
        summary: 'summary',
      );
      final mockTransaction = createMockPackageKitTransaction(
        events: [mockInfo],
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final packageKit =
          PackageKitService(dbus: createMockDbusClient(), client: mockClient);
      await packageKit.activateService();
      final info = await packageKit.resolve('foo', 'amd64');
      verify(mockTransaction.resolve(['foo'])).called(1);
      expect(info, equals(mockInfo));
    });

    test('multiple architectures', () async {
      final mockTransaction = createMockPackageKitTransaction(
        events: const [
          PackageKitPackageEvent(
            info: PackageKitInfo.available,
            packageId: PackageKitPackageId(
              name: 'foo',
              version: '1.0',
              arch: 'amd64',
            ),
            summary: 'summary',
          ),
          PackageKitPackageEvent(
            info: PackageKitInfo.available,
            packageId: PackageKitPackageId(
              name: 'foo',
              version: '1.0',
              arch: 'i386',
            ),
            summary: 'summary',
          )
        ],
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final packageKit =
          PackageKitService(dbus: createMockDbusClient(), client: mockClient);
      await packageKit.activateService();
      final info = await packageKit.resolve('foo', 'amd64');
      expect(info!.packageId.arch, equals('amd64'));
    });

    test('architecture \'all\'', () async {
      final mockTransaction = createMockPackageKitTransaction(
        events: const [
          PackageKitPackageEvent(
            info: PackageKitInfo.available,
            packageId: PackageKitPackageId(
              name: 'foo',
              version: '1.0',
              arch: 'all',
            ),
            summary: 'summary',
          ),
        ],
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final packageKit =
          PackageKitService(dbus: createMockDbusClient(), client: mockClient);
      await packageKit.activateService();
      final info = await packageKit.resolve('foo', 'all');
      expect(info!.packageId.arch, equals('all'));
    });
  });

  test('get details of local package', () async {
    final mockDetails = PackageKitPackageDetails(
      packageId: const PackageKitPackageId(
        name: 'foo',
        version: '1.0',
        arch: 'all',
      ),
      summary: 'summary',
    );
    final mockTransaction = createMockPackageKitTransaction(
      events: [mockDetails],
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit =
        PackageKitService(dbus: createMockDbusClient(), client: mockClient);
    await packageKit.activateService();
    final details = await packageKit.getDetailsLocal('/path/to/local.deb');
    verify(mockTransaction.getDetailsLocal(['/path/to/local.deb'])).called(1);
    expect(details, equals(mockDetails));
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

  test('error stream', () async {
    const mockError = PackageKitErrorCodeEvent(
      code: PackageKitError.noNetwork,
      details: 'error details',
    );
    final mockTransaction = createMockPackageKitTransaction(
      events: [mockError],
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit =
        PackageKitService(dbus: createMockDbusClient(), client: mockClient);
    await packageKit.activateService();

    packageKit.errorStream.listen(
      expectAsync1<void, PackageKitServiceError>(
        (e) {
          expect(e.code, equals(PackageKitError.noNetwork));
          expect(e.details, equals('error details'));
        },
      ),
    );
    final info = await packageKit.resolve('foo');
    expect(info, isNull);
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
