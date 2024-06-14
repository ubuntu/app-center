import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/deb/deb_page.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
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
    final debModel = createMockDebModel(
      id: 'testdeb',
      component: component,
      packageInfo: packageInfo,
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [debModelProvider.overrideWith((_, __) => debModel)],
          child: const DebPage(id: 'testdeb'),
        ));
    await tester.pump();

    expect(find.text(component.getLocalizedName()), findsOneWidget);
    expect(find.html(component.getLocalizedDescription()), findsOneWidget);
    expect(find.text(component.getLocalizedDeveloperName()), findsOneWidget);
    expect(find.text(packageInfo.packageId.version), findsOneWidget);
  });

  testWidgets('error dialog', (tester) async {
    final debModel = createMockDebModel(
      id: 'testdeb',
      component: component,
      packageInfo: packageInfo,
      errorStream: Stream.value(
        const PackageKitServiceError(
          code: PackageKitError.internalError,
          details: 'internal error',
        ),
      ),
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [debModelProvider.overrideWith((_, __) => debModel)],
          child: const DebPage(id: 'testdeb'),
        ));
    await tester.pump();

    expect(find.text('internal error'), findsOneWidget);
    expect(find.text('PackageKit error: ${PackageKitError.internalError}'),
        findsOneWidget);
  });
}
