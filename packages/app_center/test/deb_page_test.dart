import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/deb/deb_page.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:app_center/providers/current_desktops_provider.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

import 'test_utils.dart';

const packageInfo = PackageKitPackageInfo(
  info: PackageKitInfo.available,
  packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
  summary: 'summary',
);

const component = AppstreamComponent(
  id: 'testdeb',
  type: AppstreamComponentType.desktopApplication,
  package: 'testdeb-package',
  name: {'C': 'Test Deb Package'},
  summary: {'C': 'Appstream summary'},
  description: {'C': 'description'},
  developerName: {'C': 'developer name'},
);

void main() {
  testWidgets('metadata', (tester) async {
    createMockPackageKitService(packageInfo: packageInfo);
    createMockAppstreamService(component: component);

    await tester.pumpApp(
      (_) => ProviderScope(
        child: const DebPage(id: 'testdeb'),
      ),
    );
    await tester.pump();

    expect(find.text(component.getLocalizedName()), findsOneWidget);
    expect(find.html(component.getLocalizedDescription()), findsOneWidget);
    expect(find.text(component.getLocalizedDeveloperName()), findsOneWidget);
    expect(find.text(packageInfo.packageId.version), findsOneWidget);
  });

  testWidgets('error dialog', (tester) async {
    createMockPackageKitService(
      packageInfo: packageInfo,
      errorStream: Stream.value(
        const PackageKitServiceError(
          code: PackageKitError.internalError,
          details: 'internal error',
        ),
      ),
    );
    createMockAppstreamService(component: component);

    await tester.pumpApp(
      (_) => ProviderScope(
        child: const DebPage(id: 'testdeb'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('internal error'), findsOneWidget);
    expect(
      find.text('PackageKit error: ${PackageKitError.internalError}'),
      findsOneWidget,
    );
  });
  testWidgets('remove button hidden for compulsory deb on current desktop',
      (tester) async {
    const compulsoryComponent = AppstreamComponent(
      id: 'gnome-shell',
      type: AppstreamComponentType.desktopApplication,
      package: 'gnome-shell',
      name: {'C': 'GNOME Shell'},
      summary: {'C': 'GNOME desktop environment'},
      compulsoryForDesktops: ['GNOME'],
    );
    const installedPackageInfo = PackageKitPackageInfo(
      info: PackageKitInfo.installed,
      packageId: PackageKitPackageId(name: 'gnome-shell', version: '45.0'),
      summary: 'GNOME Shell',
    );
    createMockPackageKitService(packageInfo: installedPackageInfo);
    createMockAppstreamService(component: compulsoryComponent);

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          currentDesktopsProvider.overrideWithValue(['GNOME']),
        ],
        child: const DebPage(id: 'gnome-shell'),
      ),
    );
    await tester.pump();

    expect(find.text('Uninstall'), findsNothing);
  });

  testWidgets('remove button shown for non-compulsory installed deb',
      (tester) async {
    const installedPackageInfo = PackageKitPackageInfo(
      info: PackageKitInfo.installed,
      packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
      summary: 'summary',
    );
    createMockPackageKitService(packageInfo: installedPackageInfo);
    createMockAppstreamService(component: component);

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          currentDesktopsProvider.overrideWithValue(['GNOME']),
        ],
        child: const DebPage(id: 'testdeb'),
      ),
    );
    await tester.pump();

    expect(find.text('Uninstall'), findsOneWidget);
  });
}
