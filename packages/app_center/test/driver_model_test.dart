import 'dart:async';

import 'package:app_center/drivers/drivers.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

const _gpuSysPath = '/sys/devices/pci0000:00/0000:01:00.0';
const _wifiSysPath = '/sys/devices/pci0000:00/0000:02:00.0';

DriverDevice _gpuDevice({List<DriverPackage>? drivers}) => DriverDevice(
  sysPath: _gpuSysPath,
  modalias: 'pci:v000010DEd000010C3sv00003842sd00002670bc03sc03i00',
  vendor: 'NVIDIA Corporation',
  model: 'GK208 [GeForce GT 720]',
  drivers:
      drivers ??
      const [
        DriverPackage(
          name: 'nvidia-driver-550',
          source: DriverSource.distro,
          free: false,
          builtin: false,
          recommended: true,
          support: 'PB',
        ),
        DriverPackage(
          name: 'nvidia-driver-470',
          source: DriverSource.distro,
          free: false,
          builtin: false,
          recommended: false,
          support: 'LTSB',
        ),
        DriverPackage(
          name: 'xserver-xorg-video-nouveau',
          source: DriverSource.distro,
          free: true,
          builtin: true,
          recommended: false,
          support: '',
        ),
      ],
);

void main() {
  tearDown(resetAllServices);

  group('DriverBranch.fromSupport', () {
    test('maps known support values', () {
      expect(DriverBranch.fromSupport('PB'), DriverBranch.production);
      expect(DriverBranch.fromSupport('LTSB'), DriverBranch.lts);
      expect(DriverBranch.fromSupport('NFB'), DriverBranch.newFeature);
      expect(DriverBranch.fromSupport('Legacy'), DriverBranch.legacy);
    });

    test('falls back to unknown for unrecognized or empty values', () {
      expect(DriverBranch.fromSupport(''), DriverBranch.unknown);
      expect(DriverBranch.fromSupport('???'), DriverBranch.unknown);
    });

    test('only production/lts/newFeature are selectable', () {
      expect(DriverBranch.production.isSelectable, isTrue);
      expect(DriverBranch.lts.isSelectable, isTrue);
      expect(DriverBranch.newFeature.isSelectable, isTrue);
      expect(DriverBranch.legacy.isSelectable, isFalse);
      expect(DriverBranch.unknown.isSelectable, isFalse);
    });
  });

  group('DriverDeviceClass.fromModalias', () {
    test('parses PCI display controller class', () {
      expect(
        DriverDeviceClass.fromModalias(
          'pci:v000010DEd000010C3sv00003842sd00002670bc03sc03i00',
        ),
        DriverDeviceClass.graphics,
      );
    });

    test('parses PCI network controller class', () {
      expect(
        DriverDeviceClass.fromModalias('pci:v00008086d000024F3bc02sc80i00'),
        DriverDeviceClass.network,
      );
    });

    test('parses USB interface class', () {
      expect(
        DriverDeviceClass.fromModalias(
          'usb:v8087p0AAAd0001dc00dsc00dp00ic0Eisc01ip00in00',
        ),
        DriverDeviceClass.camera,
      );
    });

    test('falls back to other for empty modalias', () {
      expect(DriverDeviceClass.fromModalias(''), DriverDeviceClass.other);
    });

    test('falls back to other for unrecognized prefix', () {
      expect(
        DriverDeviceClass.fromModalias('acpi:PNP0C0A'),
        DriverDeviceClass.other,
      );
    });

    test('falls back to other for malformed class code', () {
      expect(
        DriverDeviceClass.fromModalias('pci:bcZZ'),
        DriverDeviceClass.other,
      );
    });
  });

  group('DriverDeviceInfo', () {
    DriverDeviceInfo buildInfo({
      required List<DriverBranchOption> options,
    }) => DriverDeviceInfo(
      sysPath: _gpuSysPath,
      vendor: 'NVIDIA Corporation',
      model: 'GK208',
      deviceClass: DriverDeviceClass.graphics,
      options: options,
    );

    test('section is available when nothing is installed', () {
      final info = buildInfo(
        options: [
          const DriverBranchOption(
            branch: DriverBranch.production,
            packageName: 'nvidia-driver-550',
            recommended: true,
          ),
        ],
      );
      expect(info.section, DriverSection.available);
      expect(info.installedOption, isNull);
    });

    test(
      'section is installed when a candidate is installed with no update',
      () {
        final info = buildInfo(
          options: [
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550',
              recommended: true,
              isInstalled: true,
            ),
          ],
        );
        expect(info.section, DriverSection.installed);
        expect(info.installedOption?.packageName, 'nvidia-driver-550');
      },
    );

    test(
      'section is updateAvailable when the installed candidate has an update',
      () {
        final info = buildInfo(
          options: [
            const DriverBranchOption(
              branch: DriverBranch.lts,
              packageName: 'nvidia-driver-470',
              recommended: false,
              isInstalled: true,
              hasUpdate: true,
            ),
            const DriverBranchOption(
              branch: DriverBranch.newFeature,
              packageName: 'nvidia-driver-550',
              recommended: false,
            ),
          ],
        );
        expect(info.section, DriverSection.updateAvailable);
      },
    );

    test(
      'branchOptions excludes legacy/unknown, hasBranchChoice requires 2+',
      () {
        final info = buildInfo(
          options: [
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550',
              recommended: true,
            ),
            const DriverBranchOption(
              branch: DriverBranch.lts,
              packageName: 'nvidia-driver-470',
              recommended: false,
            ),
            const DriverBranchOption(
              branch: DriverBranch.legacy,
              packageName: 'nvidia-driver-390',
              recommended: false,
            ),
            const DriverBranchOption(
              branch: DriverBranch.unknown,
              packageName: 'xserver-xorg-video-nouveau',
              recommended: false,
            ),
          ],
        );
        expect(info.branchOptions, hasLength(2));
        expect(info.hasBranchChoice, isTrue);
      },
    );

    test('a single selectable branch does not offer a branch choice', () {
      final info = buildInfo(
        options: [
          const DriverBranchOption(
            branch: DriverBranch.production,
            packageName: 'nvidia-driver-550',
            recommended: true,
          ),
        ],
      );
      expect(info.hasBranchChoice, isFalse);
    });

    test(
      'branchOptions collapses multiple packages sharing a branch into one '
      'representative, preferring the recommended package',
      () {
        final info = buildInfo(
          options: [
            // Not recommended, and listed first - an implementation that
            // just picked the first candidate would wrongly choose this one.
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550-open',
              recommended: false,
            ),
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550',
              recommended: true,
            ),
            const DriverBranchOption(
              branch: DriverBranch.lts,
              packageName: 'nvidia-driver-470',
              recommended: false,
            ),
          ],
        );
        expect(info.branchOptions, hasLength(2));
        expect(info.hasBranchChoice, isTrue);

        final production = info.branchOptions.firstWhere(
          (o) => o.branch == DriverBranch.production,
        );
        expect(production.packageName, 'nvidia-driver-550');
      },
    );

    test(
      'branchOptions prefers the installed package over the recommended one '
      'for a shared branch',
      () {
        final info = buildInfo(
          options: [
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550',
              recommended: true,
            ),
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550-open',
              recommended: false,
              isInstalled: true,
            ),
          ],
        );
        expect(info.branchOptions, hasLength(1));
        expect(info.branchOptions.single.packageName, 'nvidia-driver-550-open');
      },
    );

    test(
      'branchOptions never contains two entries for the same branch, even '
      'with several packages sharing each selectable branch',
      () {
        final info = buildInfo(
          options: [
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550',
              recommended: true,
            ),
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550-open',
              recommended: false,
            ),
            const DriverBranchOption(
              branch: DriverBranch.production,
              packageName: 'nvidia-driver-550-server',
              recommended: false,
            ),
            const DriverBranchOption(
              branch: DriverBranch.lts,
              packageName: 'nvidia-driver-470',
              recommended: true,
            ),
            const DriverBranchOption(
              branch: DriverBranch.lts,
              packageName: 'nvidia-driver-470-open',
              recommended: false,
            ),
          ],
        );
        final branches = info.branchOptions.map((o) => o.branch).toList();
        expect(branches.toSet(), hasLength(branches.length));
      },
    );
  });

  group('driverListModelProvider', () {
    test('drops devices with an empty sysPath', () async {
      registerMockDriversService(
        devices: [
          _gpuDevice(),
          _gpuDevice().copyWith(sysPath: ''),
        ],
      );
      createMockPackageKitService();
      final container = createContainer();

      final list = await container.read(driverListModelProvider.future);
      expect(list.sysPaths, [_gpuSysPath]);
    });

    test('drops builtin-only candidates and devices left with none', () async {
      registerMockDriversService(
        devices: [
          _gpuDevice(
            drivers: const [
              DriverPackage(
                name: 'xserver-xorg-video-nouveau',
                source: DriverSource.distro,
                free: true,
                builtin: true,
                recommended: false,
                support: '',
              ),
            ],
          ),
        ],
      );
      createMockPackageKitService();
      final container = createContainer();

      final list = await container.read(driverListModelProvider.future);
      expect(list.sysPaths, isEmpty);
    });

    test(
      'enriches candidates with resolve() and getUpdates() results',
      () async {
        registerMockDriversService(devices: [_gpuDevice()]);
        createMockPackageKitService(
          resolveMap: {
            'nvidia-driver-550': PackageKitPackageEvent(
              info: PackageKitInfo.installed,
              packageId: const PackageKitPackageId(
                name: 'nvidia-driver-550',
                version: '550.1',
              ),
              summary: '',
            ),
            'nvidia-driver-470': PackageKitPackageEvent(
              info: PackageKitInfo.available,
              packageId: const PackageKitPackageId(
                name: 'nvidia-driver-470',
                version: '470.1',
              ),
              summary: '',
            ),
          },
          availableUpdates: [
            PackageKitPackageEvent(
              info: PackageKitInfo.normal,
              packageId: const PackageKitPackageId(
                name: 'nvidia-driver-550',
                version: '550.2',
              ),
              summary: '',
            ),
          ],
        );
        final container = createContainer();

        final list = await container.read(driverListModelProvider.future);
        final device = list.byPath[_gpuSysPath]!;
        expect(device.section, DriverSection.updateAvailable);

        final installed = device.installedOption!;
        expect(installed.packageName, 'nvidia-driver-550');
        expect(installed.isInstalled, isTrue);
        expect(installed.hasUpdate, isTrue);
        expect(installed.updatePackageId?.version, '550.2');

        final ltsOption = device.options.firstWhere(
          (o) => o.packageName == 'nvidia-driver-470',
        );
        expect(ltsOption.isInstalled, isFalse);
        // Not installed, so a system-wide update for it doesn't count.
        expect(ltsOption.hasUpdate, isFalse);
      },
    );

    test('propagates DriversServiceException as an AsyncError', () async {
      final mock = registerMockDriversService();
      when(mock.getDrivers()).thenThrow(DriversServiceException('boom'));
      createMockPackageKitService();
      final container = createContainer();

      await expectLater(
        container.read(driverListModelProvider.future),
        throwsA(isA<DriversServiceException>()),
      );
    });
  });

  group('DriverModel', () {
    test('build reads its own device slice out of the list provider', () async {
      registerMockDriversService(devices: [_gpuDevice()]);
      createMockPackageKitService(
        resolveMap: {
          'nvidia-driver-550': PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: const PackageKitPackageId(
              name: 'nvidia-driver-550',
              version: '550.1',
            ),
            summary: '',
          ),
        },
      );
      final container = createContainer();

      final state = await container.read(
        driverModelProvider(_gpuSysPath).future,
      );
      expect(state.info.sysPath, _gpuSysPath);
      expect(state.isBusy, isFalse);
      expect(state.error, isNull);
      expect(state.requiresRestart, isFalse);
    });

    test(
      'install starts a transaction, tracks it, then clears it on success',
      () async {
        registerMockDriversService(devices: [_gpuDevice()]);
        createMockPackageKitService(transactionId: 42);
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        final notifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );

        expect(container.read(driversBusyProvider), isFalse);
        await notifier.install('nvidia-driver-550');

        final state = container.read(driverModelProvider(_gpuSysPath)).value!;
        expect(state.activeTransactionId, isNull);
        expect(state.error, isNull);
        // Busy flag self-clears once the action completes.
        expect(container.read(driversBusyProvider), isFalse);
      },
    );

    test(
      'a failed transaction records the PackageKit error scoped to this row, '
      'without touching a sibling row',
      () async {
        registerMockDriversService(
          devices: [
            _gpuDevice(),
            _gpuDevice().copyWith(sysPath: _wifiSysPath),
          ],
        );
        const packageKitError = PackageKitErrorCodeEvent(
          code: PackageKitError.packageDownloadFailed,
          details: 'network unreachable',
        );
        final packageKit = createMockPackageKitService(
          transactionId: 7,
          lastError: packageKitError,
        );
        when(packageKit.waitTransaction(7)).thenThrow(
          PackageKitTransactionError(
            'failed',
            exit: PackageKitExit.failed,
          ),
        );
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        await container.read(driverModelProvider(_wifiSysPath).future);

        final notifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );
        await notifier.install('nvidia-driver-550');

        final gpuState = container
            .read(driverModelProvider(_gpuSysPath))
            .value!;
        expect(gpuState.activeTransactionId, isNull);
        expect(gpuState.error, packageKitError);

        final wifiState = container
            .read(
              driverModelProvider(_wifiSysPath),
            )
            .value!;
        expect(wifiState.error, isNull);
        expect(wifiState.activeTransactionId, isNull);
      },
    );

    test('cancellation clears state without recording an error', () async {
      registerMockDriversService(devices: [_gpuDevice()]);
      final packageKit = createMockPackageKitService(transactionId: 3);
      when(packageKit.waitTransaction(3)).thenThrow(
        PackageKitTransactionError(
          'cancelled',
          exit: PackageKitExit.cancelled,
        ),
      );
      final container = createContainer();

      await container.read(driverModelProvider(_gpuSysPath).future);
      final notifier = container.read(
        driverModelProvider(_gpuSysPath).notifier,
      );
      await notifier.install('nvidia-driver-550');

      final state = container.read(driverModelProvider(_gpuSysPath)).value!;
      expect(state.activeTransactionId, isNull);
      expect(state.error, isNull);
    });

    test(
      'a refused cancel leaves the operation running instead of throwing',
      () async {
        registerMockDriversService(devices: [_gpuDevice()]);
        final packageKit = createMockPackageKitService(transactionId: 9);
        when(
          packageKit.cancelTransaction(9),
        ).thenThrow(Exception('cannot cancel: already unpacking'));
        // waitTransaction never completes during this test - the install
        // stays in flight while we exercise cancel().
        when(packageKit.waitTransaction(9)).thenAnswer(
          (_) => Completer<void>().future,
        );
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        final notifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );
        // Don't await: install() only completes when waitTransaction
        // resolves, which it never does here.
        unawaited(notifier.install('nvidia-driver-550'));
        await Future<void>.delayed(Duration.zero);

        await notifier.cancel();

        final state = container.read(driverModelProvider(_gpuSysPath)).value!;
        expect(state.activeTransactionId, 9);
      },
    );

    test('uninstall removes the installed candidate', () async {
      registerMockDriversService(devices: [_gpuDevice()]);
      final packageKit = createMockPackageKitService(
        transactionId: 11,
        resolveMap: {
          'nvidia-driver-550': PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: const PackageKitPackageId(
              name: 'nvidia-driver-550',
              version: '550.1',
            ),
            summary: '',
          ),
        },
      );
      when(packageKit.remove(any)).thenAnswer((_) async => 11);
      final container = createContainer();

      await container.read(driverModelProvider(_gpuSysPath).future);
      final notifier = container.read(
        driverModelProvider(_gpuSysPath).notifier,
      );
      await notifier.uninstall();

      final removedId =
          verify(packageKit.remove(captureAny)).captured.single
              as PackageKitPackageId;
      expect(removedId.name, 'nvidia-driver-550');

      final state = container.read(driverModelProvider(_gpuSysPath)).value!;
      expect(state.activeTransactionId, isNull);
    });

    test(
      'updateDriver passes the update candidate packageId, not the '
      'installed one',
      () async {
        registerMockDriversService(devices: [_gpuDevice()]);
        final packageKit = createMockPackageKitService(
          transactionId: 12,
          resolveMap: {
            'nvidia-driver-550': PackageKitPackageEvent(
              info: PackageKitInfo.installed,
              packageId: const PackageKitPackageId(
                name: 'nvidia-driver-550',
                version: '550.1',
              ),
              summary: '',
            ),
          },
          availableUpdates: [
            PackageKitPackageEvent(
              info: PackageKitInfo.normal,
              packageId: const PackageKitPackageId(
                name: 'nvidia-driver-550',
                version: '550.2',
              ),
              summary: '',
            ),
          ],
        );
        when(packageKit.update(any)).thenAnswer((_) async => 12);
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        final notifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );
        await notifier.updateDriver();

        final updatedId =
            verify(packageKit.update(captureAny)).captured.single
                as PackageKitPackageId;
        expect(updatedId.name, 'nvidia-driver-550');
        expect(updatedId.version, '550.2');
      },
    );

    test(
      'a completed transaction preserves requiresRestart across the '
      'subsequent list refresh',
      () async {
        registerMockDriversService(devices: [_gpuDevice()]);
        final packageKit = createMockPackageKitService(transactionId: 5);
        when(packageKit.requiresRestartFor(5)).thenReturn(true);
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        final notifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );
        await notifier.install('nvidia-driver-550');

        // install() invalidates driverListModelProvider, which this model
        // watches via a narrowed selector - forcing a rebuild of build().
        await container.read(driverModelProvider(_gpuSysPath).future);

        final state = container.read(driverModelProvider(_gpuSysPath)).value!;
        expect(state.requiresRestart, isTrue);
      },
    );

    test(
      'driversRequireRestartProvider is true when any device requires a '
      'restart',
      () async {
        registerMockDriversService(devices: [_gpuDevice()]);
        final packageKit = createMockPackageKitService(transactionId: 5);
        when(packageKit.requiresRestartFor(5)).thenReturn(true);
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        expect(container.read(driversRequireRestartProvider), isFalse);

        final notifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );
        await notifier.install('nvidia-driver-550');
        await container.read(driverModelProvider(_gpuSysPath).future);

        expect(container.read(driversRequireRestartProvider), isTrue);
      },
    );

    test(
      'installing an unresolved package falls back to an empty version id',
      () async {
        registerMockDriversService(
          devices: [
            _gpuDevice(
              drivers: const [
                DriverPackage(
                  name: 'nvidia-driver-550',
                  source: DriverSource.distro,
                  free: false,
                  builtin: false,
                  recommended: true,
                  support: 'PB',
                ),
              ],
            ),
          ],
        );
        // resolveMap without an entry for nvidia-driver-550 means
        // resolve() returns a null packageInfo for it.
        final packageKit = createMockPackageKitService(
          resolveMap: const {},
          transactionId: 13,
        );
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        final notifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );
        await notifier.install('nvidia-driver-550');

        final captured =
            verify(packageKit.install(captureAny)).captured.single
                as PackageKitPackageId;
        expect(captured.name, 'nvidia-driver-550');
        expect(captured.version, isEmpty);
      },
    );

    test(
      'a second operation is refused while one is already in progress',
      () async {
        registerMockDriversService(
          devices: [
            _gpuDevice(),
            _gpuDevice().copyWith(sysPath: _wifiSysPath),
          ],
        );
        final packageKit = createMockPackageKitService(transactionId: 21);
        when(packageKit.waitTransaction(21)).thenAnswer(
          (_) => Completer<void>().future,
        );
        final container = createContainer();

        await container.read(driverModelProvider(_gpuSysPath).future);
        await container.read(driverModelProvider(_wifiSysPath).future);

        final gpuNotifier = container.read(
          driverModelProvider(_gpuSysPath).notifier,
        );
        final wifiNotifier = container.read(
          driverModelProvider(_wifiSysPath).notifier,
        );

        expect(gpuNotifier.canOperate, isTrue);
        unawaited(gpuNotifier.install('nvidia-driver-550'));
        await Future<void>.delayed(Duration.zero);

        expect(container.read(driversBusyProvider), isTrue);
        expect(gpuNotifier.canOperate, isFalse);
        expect(wifiNotifier.canOperate, isFalse);
        expect(
          () => wifiNotifier.install('nvidia-driver-550'),
          throwsA(isA<StateError>()),
        );
      },
    );
  });
}
