import 'package:app_center/drivers/drivers.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_test/yaru_test.dart';

import 'test_utils.dart';

const _gpuSysPath = '/sys/devices/pci0000:00/0000:01:00.0';
const _wifiSysPath = '/sys/devices/pci0000:00/0000:02:00.0';

DriverDevice _gpuDevice() => const DriverDevice(
  sysPath: _gpuSysPath,
  modalias: 'pci:v000010DEd000010C3sv00003842sd00002670bc03sc03i00',
  vendor: 'NVIDIA Corporation',
  model: 'GK208 [GeForce GT 720]',
  drivers: [
    DriverPackage(
      name: 'nvidia-driver-550',
      source: DriverSource.distro,
      free: false,
      builtin: false,
      recommended: true,
      support: 'PB',
    ),
  ],
);

DriverDevice _wifiDevice() => const DriverDevice(
  sysPath: _wifiSysPath,
  modalias: 'pci:v00008086d000024FDsv00008086sd00000080bc02sc80i00',
  vendor: 'Intel Corporation',
  model: 'Wireless 7265',
  drivers: [
    DriverPackage(
      name: 'bcmwl-kernel-source',
      source: DriverSource.distro,
      free: false,
      builtin: false,
      recommended: true,
      support: 'PB',
    ),
  ],
);

void main() {
  tearDown(resetAllServices);

  testWidgets('shows an available device with an install button', (
    tester,
  ) async {
    registerMockDriversService(devices: [_gpuDevice()]);
    createMockPackageKitService(
      resolveMap: {
        'nvidia-driver-550': const PackageKitPackageInfo(
          info: PackageKitInfo.available,
          packageId: PackageKitPackageId(
            name: 'nvidia-driver-550',
            version: '550.0',
          ),
          summary: 'summary',
        ),
      },
    );

    await tester.pumpApp((_) => const ProviderScope(child: DriversPage()));
    await tester.pumpAndSettle();

    expect(find.text('GK208 [GeForce GT 720]'), findsOneWidget);
    expect(
      find.text(tester.l10n.driversPageSectionAvailable),
      findsOneWidget,
    );
    expect(find.button(tester.l10n.snapActionInstallLabel), findsOneWidget);
  });

  testWidgets('shows an installed device with an update available', (
    tester,
  ) async {
    registerMockDriversService(devices: [_gpuDevice()]);
    createMockPackageKitService(
      resolveMap: {
        'nvidia-driver-550': const PackageKitPackageInfo(
          info: PackageKitInfo.installed,
          packageId: PackageKitPackageId(
            name: 'nvidia-driver-550',
            version: '550.0',
          ),
          summary: 'summary',
        ),
      },
      availableUpdates: const [
        PackageKitPackageInfo(
          info: PackageKitInfo.normal,
          packageId: PackageKitPackageId(
            name: 'nvidia-driver-550',
            version: '552.0',
          ),
          summary: 'summary',
        ),
      ],
    );

    await tester.pumpApp((_) => const ProviderScope(child: DriversPage()));
    await tester.pumpAndSettle();

    expect(
      find.text(tester.l10n.driversPageSectionUpdateAvailable),
      findsOneWidget,
    );
    expect(find.button(tester.l10n.snapActionUpdateLabel), findsOneWidget);
  });

  testWidgets('uninstalls instantly from the menu action', (tester) async {
    registerMockDriversService(devices: [_wifiDevice()]);
    final packageKit = createMockPackageKitService(
      resolveMap: {
        'bcmwl-kernel-source': const PackageKitPackageInfo(
          info: PackageKitInfo.installed,
          packageId: PackageKitPackageId(
            name: 'bcmwl-kernel-source',
            version: '6.30',
          ),
          summary: 'summary',
        ),
      },
    );

    await tester.pumpApp((_) => const ProviderScope(child: DriversPage()));
    await tester.pumpAndSettle();

    expect(
      find.text(tester.l10n.driversPageSectionInstalled),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(YaruIcons.view_more));
    await tester.pumpAndSettle();

    expect(find.text(tester.l10n.snapActionRemoveLabel), findsOneWidget);
    await tester.tap(find.text(tester.l10n.snapActionRemoveLabel));
    await tester.pumpAndSettle();

    verify(
      packageKit.remove(
        const PackageKitPackageId(
          name: 'bcmwl-kernel-source',
          version: '6.30',
        ),
      ),
    ).called(1);
  });

  testWidgets('shows a message when no drivers are found', (tester) async {
    registerMockDriversService(devices: const []);
    createMockPackageKitService();

    await tester.pumpApp((_) => const ProviderScope(child: DriversPage()));
    await tester.pumpAndSettle();

    expect(
      find.text(tester.l10n.driversPageNoDriversFoundMessage),
      findsOneWidget,
    );
    expect(find.text(tester.l10n.driversPageSectionAvailable), findsNothing);
  });

  testWidgets('shows an unsupported message if the service is unavailable', (
    tester,
  ) async {
    registerMockDriversService(unavailable: true);
    createMockPackageKitService();

    await tester.pumpApp((_) => const ProviderScope(child: DriversPage()));
    await tester.pumpAndSettle();

    expect(
      find.text(tester.l10n.driversPageUnsupportedMessage),
      findsOneWidget,
    );
  });
}
