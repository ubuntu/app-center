import 'package:app_center/gstreamer/gstreamer_page.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'test_utils.dart';

void main() {
  const resources = [
    (
      id: 'gstreamer1(decoder-video/x-h265)()(64bit)',
      name: 'H.265 (Main Profile) decoder',
    ),
  ];
  final mockPackage = PackageKitPackageDetails(
    packageId: const PackageKitPackageId(name: 'testdeb', version: '1.0'),
    summary: 'summary',
    description: 'description',
    license: 'license',
    size: 42,
    url: 'url',
  );

  testWidgets('gstreamer', (tester) async {
    final packageKit = createMockPackageKitService(
      packageEvents: [
        PackageKitPackageEvent(
          info: PackageKitInfo.available,
          packageId: mockPackage.packageId,
          summary: mockPackage.summary,
        ),
      ],
    );
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => ProviderScope(
        child: const GStreamerPage(resources: resources),
      ),
    );
    await tester.pump();

    expect(find.text(tester.l10n.codecPageTitle), findsOneWidget);
    expect(find.text(tester.l10n.codecPageDescription), findsOneWidget);
    expect(find.text('H.265 (Main Profile) decoder'), findsOne);
  });

  testWidgets('installAll', (tester) async {
    final event = PackageKitPackageEvent(
      info: PackageKitInfo.available,
      packageId: mockPackage.packageId,
      summary: mockPackage.summary,
    );
    final packageKit = createMockPackageKitService(
      packageEvents: [event],
      packageInfo: event,
    );
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => ProviderScope(
        child: const GStreamerPage(resources: resources),
      ),
    );
    await tester.pumpAndSettle();

    final installButton = find.text(tester.l10n.codecInstallAllButton);
    expect(installButton, findsOneWidget);
    await tester.tap(installButton);
    await tester.pump();

    verify(packageKit.installAll([mockPackage.packageId])).called(1);
  });
}
