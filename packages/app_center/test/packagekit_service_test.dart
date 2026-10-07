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

    test('service reactivated after losing its D-Bus owner', () async {
      final ownerChanges = StreamController<DBusNameOwnerChangedEvent>();
      final dbus = createMockDbusClient();
      when(dbus.nameOwnerChanged).thenAnswer((_) => ownerChanges.stream);
      final packageKit = PackageKitService(
        dbus: dbus,
        client: createMockPackageKitClient(),
        fs: MemoryFileSystem.test(),
      );

      await packageKit.install(
        const PackageKitPackageId(name: 'foo', version: '1.0'),
      );
      ownerChanges.add(
        const DBusNameOwnerChangedEvent(
          _packageKitDBusName,
          oldOwner: ':1.0',
        ),
      );
      await pumpEventQueue();
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
      ).called(2);
      await ownerChanges.close();
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
    final id = await packageKit.install(
      const PackageKitPackageId(name: 'foo', version: '1.0'),
    );
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

  group('simulateInstall', () {
    test(
      'uses simulation and returns only added or replaced packages',
      () async {
        final events = [
          for (final info in [
            PackageKitInfo.installing,
            PackageKitInfo.updating,
            PackageKitInfo.downgrading,
            PackageKitInfo.reinstalling,
            PackageKitInfo.installed,
            PackageKitInfo.removing,
            PackageKitInfo.obsoleting,
            PackageKitInfo.untrusted,
          ])
            PackageKitPackageEvent(
              info: info,
              packageId: PackageKitPackageId(name: info.name, version: '1.0'),
              summary: info.name,
            ),
        ];
        final transaction = createMockPackageKitTransaction(events: events);
        final packageKit = PackageKitService(
          dbus: createMockDbusClient(),
          client: createMockPackageKitClient(transaction: transaction),
          fs: MemoryFileSystem.test(),
        );
        addTearDown(packageKit.dispose);
        final ids = [events.first.packageId];
        final packages = await packageKit.simulateInstall(ids);
        expect(packages, events.take(4));
        verify(
          transaction.installPackages(
            ids,
            transactionFlags: {PackageKitTransactionFlag.simulate},
          ),
        ).called(1);
      },
    );

    test('propagates failed simulation', () async {
      final transaction = createMockPackageKitTransaction(
        exit: PackageKitExit.failed,
      );
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: createMockPackageKitClient(transaction: transaction),
        fs: MemoryFileSystem.test(),
      );
      addTearDown(packageKit.dispose);
      await expectLater(
        packageKit.simulateInstall([
          const PackageKitPackageId(name: 'foo', version: '1.0'),
        ]),
        throwsA(isA<PackageKitTransactionError>()),
      );
    });

    test('empty input does not create a transaction', () async {
      final client = createMockPackageKitClient();
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: client,
        fs: MemoryFileSystem.test(),
      );
      addTearDown(packageKit.dispose);
      expect(await packageKit.simulateInstall([]), isEmpty);
      verifyNever(client.createTransaction());
    });
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

    final packages = await packageKit.whatProvides(
      'gstreamer1(decoder-video/x-h265)()(64bit)',
    );
    verify(
      mockTransaction.whatProvides([
        'gstreamer1(decoder-video/x-h265)()(64bit)',
      ]),
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
    final id = await packageKit.remove(
      const PackageKitPackageId(name: 'foo', version: '1.0'),
    );
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
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final info = (await packageKit.resolve([
        'foo',
      ], architecture: 'amd64'))['foo'];
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
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final info = (await packageKit.resolve([
        'foo',
      ], architecture: 'amd64'))['foo'];
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
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final info = (await packageKit.resolve([
        'foo',
      ], architecture: 'all'))['foo'];
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
    final id = await packageKit.install(
      const PackageKitPackageId(name: 'foo', version: '1.0'),
    );
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

  test(
    'waitTransaction throws PackageKitTransactionCancelled when cancelled',
    () async {
      final mockTransaction = createMockPackageKitTransaction(
        exit: PackageKitExit.cancelled,
      );
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final id = await packageKit.install(
        const PackageKitPackageId(name: 'foo', version: '1.0'),
      );
      await expectLater(
        packageKit.waitTransaction(id),
        throwsA(isA<PackageKitTransactionCancelled>()),
      );
    },
  );

  test(
    'waitTransaction throws PackageKitTransactionCancelled when polkit dialog is dismissed',
    () async {
      /* The daemon fails the transaction (exit=failed) after a notAuthorized
         error code — PackageKit has no cancelled exit code for this case. */
      final startCompleter = Completer();
      final mockTransaction = createMockPackageKitTransaction(
        events: [
          const PackageKitErrorCodeEvent(
            code: PackageKitError.notAuthorized,
            details: 'Failed to obtain authentication.',
          ),
        ],
        exit: PackageKitExit.failed,
        start: startCompleter.future,
      );
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final id = await packageKit.install(
        const PackageKitPackageId(name: 'foo', version: '1.0'),
      );
      final future = packageKit.waitTransaction(id);
      startCompleter.complete();
      await expectLater(
        future,
        throwsA(isA<PackageKitTransactionCancelled>()),
      );
    },
  );

  test('error stream ignores user cancellations', () async {
    final startCompleter = Completer();
    final mockTransaction = createMockPackageKitTransaction(
      events: [
        const PackageKitErrorCodeEvent(
          code: PackageKitError.notAuthorized,
          details: 'Failed to obtain authentication.',
        ),
        const PackageKitErrorCodeEvent(
          code: PackageKitError.noNetwork,
          details: 'error details',
        ),
      ],
      exit: PackageKitExit.failed,
      start: startCompleter.future,
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final errors = <PackageKitServiceError>[];
    packageKit.errorStream.listen(errors.add);
    final id = await packageKit.install(
      const PackageKitPackageId(name: 'foo', version: '1.0'),
    );
    final future = packageKit.waitTransaction(id);
    startCompleter.complete();
    await expectLater(
      future,
      throwsA(isA<PackageKitTransactionCancelled>()),
    );
    expect(
      errors.map((e) => e.code),
      equals([PackageKitError.noNetwork]),
    );
  });

  test(
    'waitTransaction throws PackageKitTransactionError on non-cancelled exit',
    () async {
      final mockTransaction = createMockPackageKitTransaction(
        exit: PackageKitExit.failed,
      );
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: mockClient,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();
      final id = await packageKit.install(
        const PackageKitPackageId(name: 'foo', version: '1.0'),
      );
      await expectLater(
        packageKit.waitTransaction(id),
        throwsA(
          isA<PackageKitTransactionError>()
              .having((e) => e.message, 'message', contains('failed'))
              // A failure must not look like a user cancellation.
              .having(
                (e) => e is PackageKitTransactionCancelled,
                'isCancelled',
                isFalse,
              ),
        ),
      );
    },
  );

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

  test(
    'lastErrorFor is scoped to the transaction that produced the error',
    () async {
      const errorA = PackageKitErrorCodeEvent(
        code: PackageKitError.noNetwork,
        details: 'network unreachable',
      );
      final transactionA = createMockPackageKitTransaction(events: [errorA]);
      final transactionB = createMockPackageKitTransaction();
      final client = createMockPackageKitClient();
      final transactions = [transactionA, transactionB];
      var callCount = 0;
      when(
        client.createTransaction(),
      ).thenAnswer((_) async => transactions[callCount++]);
      final packageKit = PackageKitService(
        dbus: createMockDbusClient(),
        client: client,
        fs: MemoryFileSystem.test(),
      );
      await packageKit.activateService();

      final idA = await packageKit.install(
        const PackageKitPackageId(name: 'foo', version: '1.0'),
      );
      await packageKit.waitTransaction(idA);
      final idB = await packageKit.install(
        const PackageKitPackageId(name: 'bar', version: '2.0'),
      );
      await packageKit.waitTransaction(idB);

      expect(packageKit.lastErrorFor(idA), equals(errorA));
      expect(packageKit.lastErrorFor(idB), isNull);
    },
  );

  test('getDetails for multiple packages', () async {
    final fooDetails = PackageKitDetailsEvent(
      packageId: const PackageKitPackageId(
        name: 'foo',
        version: '1.0',
        arch: 'amd64',
      ),
      summary: 'foo summary',
    );
    final barDetails = PackageKitDetailsEvent(
      packageId: const PackageKitPackageId(
        name: 'bar',
        version: '2.0',
        arch: 'amd64',
      ),
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
      packageId: PackageKitPackageId(
        name: 'foo',
        version: '1.0',
        arch: 'amd64',
      ),
      summary: 'foo summary',
    );
    const barPackage = PackageKitPackageEvent(
      info: PackageKitInfo.installed,
      packageId: PackageKitPackageId(
        name: 'bar',
        version: '2.0',
        arch: 'amd64',
      ),
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
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
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
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
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
      final mockClient = createMockPackageKitClient(
        transaction: mockTransaction,
      );
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

    test(
      'copies file to runtime dir when GetHostPaths is unavailable',
      () async {
        final completer = Completer();
        final mockTransaction = createMockPackageKitTransaction(
          start: completer.future,
        );
        final mockClient = createMockPackageKitClient(
          transaction: mockTransaction,
        );
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
      },
    );
  });

  test('getUpdates', () async {
    const fooUpdate = PackageKitPackageEvent(
      info: PackageKitInfo.normal,
      packageId: PackageKitPackageId(
        name: 'foo',
        version: '2.0',
        arch: 'amd64',
      ),
      summary: 'foo update',
    );
    const barUpdate = PackageKitPackageEvent(
      info: PackageKitInfo.normal,
      packageId: PackageKitPackageId(
        name: 'bar',
        version: '3.0',
        arch: 'amd64',
      ),
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

  test('getUpdates excludes blocked updates', () async {
    const availableUpdate = PackageKitPackageEvent(
      info: PackageKitInfo.normal,
      packageId: PackageKitPackageId(
        name: 'foo',
        version: '2.0',
        arch: 'amd64',
      ),
      summary: 'foo update',
    );
    const blockedUpdate = PackageKitPackageEvent(
      info: PackageKitInfo.blocked,
      packageId: PackageKitPackageId(
        name: 'bar',
        version: '3.0',
        arch: 'amd64',
      ),
      summary: 'bar blocked (phased) update',
    );
    final mockTransaction = createMockPackageKitTransaction(
      events: [availableUpdate, blockedUpdate],
    );
    final mockClient = createMockPackageKitClient(transaction: mockTransaction);
    final packageKit = PackageKitService(
      dbus: createMockDbusClient(),
      client: mockClient,
      fs: MemoryFileSystem.test(),
    );
    await packageKit.activateService();

    final updates = await packageKit.getUpdates();
    expect(updates, contains(availableUpdate));
    expect(updates, isNot(contains(blockedUpdate)));
    expect(updates.length, equals(1));
  });

  group('mutation events', () {
    const foo = PackageKitPackageId(name: 'foo', version: '1.0');
    const bar = PackageKitPackageId(name: 'bar', version: '2.0');

    PackageKitService createService(PackageKitTransaction transaction) =>
        PackageKitService(
          dbus: createMockDbusClient(),
          client: createMockPackageKitClient(transaction: transaction),
          fs: MemoryFileSystem.test(),
        );

    test('reports progress and success', () async {
      final packageKit = createService(
        createMockPackageKitTransaction(percentages: const [30, 101]),
      );
      final events = <PackageKitMutation>[];
      packageKit.mutationEvents.listen(events.add);

      final id = await packageKit.install(foo);
      expect(packageKit.activeMutations.single.transactionId, id);
      await packageKit.waitTransaction(id);
      await pumpEventQueue();

      expect(events.map((e) => e.percentage), [null, 30, 30]);
      expect(events.last.outcome, PackageKitMutationOutcome.success);
      expect(events.first.kind, PackageKitMutationKind.install);
      expect(events.first.affects('foo'), isTrue);
      expect(packageKit.activeMutations, isEmpty);
      expect(packageKit.mutation(id)?.isTerminal, isTrue);
    });

    test('attributes batch updates to every package', () async {
      final packageKit = createService(createMockPackageKitTransaction());
      final events = <PackageKitMutation>[];
      packageKit.mutationEvents.listen(events.add);

      await packageKit.updateAll([foo, bar]);
      await pumpEventQueue();

      expect(events.first.kind, PackageKitMutationKind.update);
      expect(events.first.affects('bar'), isTrue);
      expect(events.last.outcome, PackageKitMutationOutcome.success);
    });

    test('declined authorization is a cancellation', () async {
      final packageKit = createService(
        createMockPackageKitTransaction(
          events: const [
            PackageKitErrorCodeEvent(
              code: PackageKitError.notAuthorized,
              details: 'declined',
            ),
          ],
          exit: PackageKitExit.failed,
        ),
      );

      final id = await packageKit.remove(foo);
      await expectLater(
        packageKit.waitTransaction(id),
        throwsA(isA<PackageKitTransactionError>()),
      );
      expect(
        packageKit.mutation(id)?.outcome,
        PackageKitMutationOutcome.cancelled,
      );
    });

    test('failure is scoped to its transaction', () async {
      final packageKit = createService(
        createMockPackageKitTransaction(exit: PackageKitExit.failed),
      );

      final id = await packageKit.update(foo);
      await expectLater(
        packageKit.waitTransaction(id),
        throwsA(isA<PackageKitTransactionError>()),
      );
      expect(
        packageKit.mutation(id)?.outcome,
        PackageKitMutationOutcome.failed,
      );
      expect(packageKit.mutation(id)?.packageIds, [foo]);
    });

    test('queries are not mutations', () async {
      final packageKit = createService(createMockPackageKitTransaction());
      final events = <PackageKitMutation>[];
      packageKit.mutationEvents.listen(events.add);

      await packageKit.getUpdates();
      await pumpEventQueue();

      expect(events, isEmpty);
    });

    test('start failure is terminal', () async {
      final transaction = createMockPackageKitTransaction();
      when(transaction.installPackages(any)).thenThrow(Exception('denied'));
      final packageKit = createService(transaction);
      final events = <PackageKitMutation>[];
      packageKit.mutationEvents.listen(events.add);

      await expectLater(packageKit.install(foo), throwsException);
      await pumpEventQueue();

      expect(events.last.outcome, PackageKitMutationOutcome.failed);
      expect(packageKit.activeMutations, isEmpty);
    });
  });
}

@GenerateMocks([DBusClient, XdgDocumentsPortal])
MockDBusClient createMockDbusClient() {
  final dbus = MockDBusClient();
  when(dbus.nameOwnerChanged).thenAnswer((_) => const Stream.empty());
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
