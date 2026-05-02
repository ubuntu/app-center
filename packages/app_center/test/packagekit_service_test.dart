import 'dart:async';
import 'dart:io' as io;

import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:dbus/dbus.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:xdg_desktop_portal/xdg_desktop_portal.dart';

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
      final packageKit = PackageKitService(
        dbus: dbus,
        client: createMockPackageKitClient(),
        fs: MemoryFileSystem.test(),
      );
      expect(packageKit.isAvailable, isFalse);
      await packageKit.activateService();
      verify(
        dbus.callMethod(
          path: DBusObjectPath(_dBusObjectPath),
          destination: _dBusName,
          name: 'StartServiceByName',
          interface: _dBusInterface,
          values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
        ),
      ).called(1);
      expect(packageKit.isAvailable, isTrue);

      await packageKit.activateService();
      verifyNever(
        dbus.callMethod(
          path: DBusObjectPath(_dBusObjectPath),
          destination: _dBusName,
          name: 'StartServiceByName',
          interface: _dBusInterface,
          values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
        ),
      );
    });

    test('service unavailable', () async {
      final dbus = createMockDbusClient();
      final client = createMockPackageKitClient();
      when(client.connect()).thenThrow(
        DBusServiceUnknownException(
          DBusMethodErrorResponse('org.freedesktop.DBus.Error.ServiceUnknown'),
        ),
      );
      final packageKit = PackageKitService(
        dbus: dbus,
        client: client,
        fs: MemoryFileSystem.test(),
      );
      expect(packageKit.isAvailable, isFalse);
      await packageKit.activateService();
      verify(
        dbus.callMethod(
          path: DBusObjectPath(_dBusObjectPath),
          destination: _dBusName,
          name: 'StartServiceByName',
          interface: _dBusInterface,
          values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
        ),
      ).called(1);
      expect(packageKit.isAvailable, isFalse);
    });
  });

  test('install', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();
    final id = await packageKit
        .install(const PackageKitPackageId(name: 'foo', version: '1.0'));
    verify(
      mockTransaction.installPackages(
        [const PackageKitPackageId(name: 'foo', version: '1.0')],
      ),
    ).called(1);
    final transaction = packageKit.getTransaction(id);
    expect(transaction, isNotNull);
    completer.complete();
    await packageKit.waitTransaction(id);
    expect(packageKit.getTransaction(id), isNull);
  });

  test('installAll', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final packages = [
      const PackageKitPackageId(name: 'foo', version: '1.0'),
      const PackageKitPackageId(name: 'bar', version: '2.0'),
    ];
    final id = await packageKit.installAll(packages);
    verify(mockTransaction.installPackages(packages)).called(1);
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
    final mockFs = MemoryFileSystem.test();
    mockFs.file('/path/to/local.deb').createSync(recursive: true);
    mockFs.currentDirectory = mockFs.directory('/path');
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: mockFs,
    );
    await packageKit.activateService();
    final id = await packageKit.installLocal('to/local.deb');
    verify(mockTransaction.installFiles(['/path/to/local.deb'])).called(1);
    final transaction = packageKit.getTransaction(id);
    expect(transaction, isNotNull);
    completer.complete();
    await packageKit.waitTransaction(id);
    expect(packageKit.getTransaction(id), isNull);
  });

  test('whatProvides', () async {
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
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final packages = await packageKit
        .whatProvides('gstreamer1(decoder-video/x-h265)()(64bit)');
    verify(
      mockTransaction
          .whatProvides(['gstreamer1(decoder-video/x-h265)()(64bit)']),
    ).called(1);
    expect(packages, contains(mockInfo));
  });

  test('remove', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();
    final id = await packageKit
        .remove(const PackageKitPackageId(name: 'foo', version: '1.0'));
    verify(
      mockTransaction.removePackages(
        [const PackageKitPackageId(name: 'foo', version: '1.0')],
      ),
    ).called(1);
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
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final info =
          (await packageKit.resolve(['foo'], architecture: 'amd64'))['foo'];
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
          ),
        ],
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final info =
          (await packageKit.resolve(['foo'], architecture: 'amd64'))['foo'];
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
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final info =
          (await packageKit.resolve(['foo'], architecture: 'all'))['foo'];
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
    final mockFs = MemoryFileSystem.test();
    mockFs.file('/path/to/local.deb').createSync(recursive: true);
    mockFs.currentDirectory = mockFs.directory('/path/to');
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: mockFs,
    );
    await packageKit.activateService();
    final details = await packageKit.getDetailsLocal('local.deb');
    verify(mockTransaction.getDetailsLocal(['/path/to/local.deb'])).called(1);
    expect(details, equals(mockDetails));
  });

  test('cancel', () async {
    final completer = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      start: completer.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();
    final id = await packageKit
        .install(const PackageKitPackageId(name: 'foo', version: '1.0'));
    verify(
      mockTransaction.installPackages(
        [const PackageKitPackageId(name: 'foo', version: '1.0')],
      ),
    ).called(1);
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
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    packageKit.errorStream.listen(
      expectAsync1<void, PackageKitServiceError>(
        (e) {
          expect(e.code, equals(PackageKitError.noNetwork));
          expect(e.details, equals('error details'));
        },
      ),
    );
    final info = (await packageKit.resolve(['foo']))['foo'];
    expect(info, isNull);
  });

  test('getDetails for multiple packages', () async {
    final fooDetails = PackageKitDetailsEvent(
      packageId:
          const PackageKitPackageId(name: 'foo', version: '1.0', arch: 'amd64'),
      summary: 'foo summary',
    );
    final barDetails = PackageKitDetailsEvent(
      packageId:
          const PackageKitPackageId(name: 'bar', version: '2.0', arch: 'amd64'),
      summary: 'bar summary',
    );
    final mockTransaction = createMockPackageKitTransaction(
      events: [fooDetails, barDetails],
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final packageIds = [
      const PackageKitPackageId(name: 'foo', version: '1.0', arch: 'amd64'),
      const PackageKitPackageId(name: 'bar', version: '2.0', arch: 'amd64'),
    ];
    final details = await packageKit.getDetails(packageIds);
    verify(mockTransaction.getDetails(packageIds)).called(1);
    expect(details['foo'], equals(fooDetails));
    expect(details['bar'], equals(barDetails));
  });

  test('updateAll', () async {
    final mockTransaction = createMockPackageKitTransaction();
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final packages = [
      const PackageKitPackageId(name: 'foo', version: '1.0'),
      const PackageKitPackageId(name: 'bar', version: '2.0'),
    ];
    await packageKit.updateAll(packages);
    verify(mockTransaction.updatePackages(packages)).called(1);
  });

  test('getInstalledPackages', () async {
    const fooPackage = PackageKitPackageEvent(
      info: PackageKitInfo.installed,
      packageId:
          PackageKitPackageId(name: 'foo', version: '1.0', arch: 'amd64'),
      summary: 'foo summary',
    );
    const barPackage = PackageKitPackageEvent(
      info: PackageKitInfo.installed,
      packageId:
          PackageKitPackageId(name: 'bar', version: '2.0', arch: 'amd64'),
      summary: 'bar summary',
    );
    final mockTransaction = createMockPackageKitTransaction(
      events: [fooPackage, barPackage],
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final packages = await packageKit.getInstalledPackages();
    verify(
      mockTransaction.getPackages(filter: {PackageKitFilter.installed}),
    ).called(1);
    expect(packages, contains(fooPackage));
    expect(packages, contains(barPackage));
    expect(packages.length, equals(2));
  });

  group('portal path resolution', () {
    const portalPath = '/run/user/1000/doc/8cf4b075/test-package_1.0_amd64.deb';
    const realPath = '/home/user/Downloads/test-package_1.0_amd64.deb';

    test('install local package via portal path', () async {
      final completer = Completer();
      final mockTransaction = createMockPackageKitTransaction(
        start: completer.future,
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        documentsPortal: createMockDocumentsPortal(
          docId: '8cf4b075',
          realPath: realPath,
        ),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final id = await packageKit.installLocal(portalPath);
      verify(mockTransaction.installFiles([realPath])).called(1);
      completer.complete();
      await packageKit.waitTransaction(id);
    });

    test('get details of local package via portal path', () async {
      final mockDetails = PackageKitPackageDetails(
        packageId: const PackageKitPackageId(
          name: 'test-package',
          version: '1.0',
          arch: 'amd64',
        ),
        summary: 'summary',
      );
      final mockTransaction = createMockPackageKitTransaction(
        events: [mockDetails],
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        documentsPortal: createMockDocumentsPortal(
          docId: '8cf4b075',
          realPath: realPath,
        ),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final details = await packageKit.getDetailsLocal(portalPath);
      verify(mockTransaction.getDetailsLocal([realPath])).called(1);
      expect(details, equals(mockDetails));
    });

    test('falls back to absolute path when portal is unavailable', () async {
      final completer = Completer();
      final mockTransaction = createMockPackageKitTransaction(
        start: completer.future,
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        documentsPortal: createMockDocumentsPortal(portalUnavailable: true),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final id = await packageKit.installLocal(portalPath);
      // _isPortalPath returns false when getMountPoint fails, so the raw path
      // is passed through _getAbsolutePath (which equals portalPath on MemoryFS)
      verify(mockTransaction.installFiles([portalPath])).called(1);
      completer.complete();
      await packageKit.waitTransaction(id);
    });

    test('copies file to runtime dir when GetHostPaths is unavailable',
        () async {
      final completer = Completer();
      final mockTransaction = createMockPackageKitTransaction(
        start: completer.future,
      );
      final mockClient =
          createMockPackageKitClient(transaction: mockTransaction);
      final fs = MemoryFileSystem.test();
      const portalPathForCopy =
          '/run/user/1000/doc/8cf4b075/test-package_1.0_amd64.deb';
      const runtimeDir = '/run/user/1000';
      await fs.file(portalPathForCopy).create(recursive: true);
      await fs.directory(runtimeDir).create(recursive: true);
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        documentsPortal: createMockDocumentsPortal(
          docId: '8cf4b075',
          getHostPathsUnknown: true,
        ),
        client: mockClient,
        fs: fs,
        runtimeDir: runtimeDir,
      );
      await packageKit.activateService();
      final id = await packageKit.installLocal(portalPathForCopy);
      verify(
        mockTransaction.installFiles(
          argThat(
            predicate<List<String>>(
              (paths) =>
                  paths.length == 1 &&
                  paths.first.startsWith('$runtimeDir/packagekit-') &&
                  paths.first.endsWith('test-package_1.0_amd64.deb'),
            ),
          ),
        ),
      ).called(1);
      final tempDir = fs
          .directory(runtimeDir)
          .listSync()
          .whereType<Directory>()
          .firstWhere((d) => d.basename.startsWith('packagekit-'));
      expect(tempDir.existsSync(), isTrue);
      completer.complete();
      await packageKit.waitTransaction(id);
      // Give onDone callback a chance to run
      await Future<void>.delayed(Duration.zero);
      expect(tempDir.existsSync(), isFalse);
    });
  });

  test('getUpdates', () async {
    const fooUpdate = PackageKitPackageEvent(
      info: PackageKitInfo.normal,
      packageId:
          PackageKitPackageId(name: 'foo', version: '2.0', arch: 'amd64'),
      summary: 'foo update',
    );
    const barUpdate = PackageKitPackageEvent(
      info: PackageKitInfo.normal,
      packageId:
          PackageKitPackageId(name: 'bar', version: '3.0', arch: 'amd64'),
      summary: 'bar update',
    );
    final mockTransaction = createMockPackageKitTransaction(
      events: [fooUpdate, barUpdate],
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final updates = await packageKit.getUpdates();
    verify(mockTransaction.getUpdates()).called(1);
    expect(updates, contains(fooUpdate));
    expect(updates, contains(barUpdate));
    expect(updates.length, equals(2));
  });
}

@GenerateMocks([DBusClient, XdgDocumentsPortal])
MockDBusClient createMockDbusClient() {
  final dbus = MockDBusClient();
  when(
    dbus.callMethod(
      path: DBusObjectPath(_dBusObjectPath),
      destination: _dBusName,
      name: 'StartServiceByName',
      interface: _dBusInterface,
      values: const [DBusString(_packageKitDBusName), DBusUint32(0)],
    ),
  ).thenAnswer((_) async => DBusMethodSuccessResponse());
  return dbus;
}

MockXdgDocumentsPortal createMockDocumentsPortal({
  String? docId,
  String? realPath,
  String mountPoint = '/run/user/1000/doc',
  bool portalUnavailable = false,
  bool getHostPathsUnknown = false,
}) {
  final portal = MockXdgDocumentsPortal();
  if (portalUnavailable) {
    when(portal.getMountPoint()).thenThrow(Exception('portal unavailable'));
  } else {
    when(portal.getMountPoint()).thenAnswer(
      (_) async => io.Directory(mountPoint),
    );
    if (getHostPathsUnknown) {
      when(portal.getHostPaths([docId!])).thenThrow(
        DBusUnknownMethodException(DBusMethodErrorResponse.unknownMethod()),
      );
    } else {
      when(portal.getHostPaths([docId!])).thenAnswer(
        (_) async => {docId: io.File(realPath!)},
      );
    }
  }
  return portal;
}
