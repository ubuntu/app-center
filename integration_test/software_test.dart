import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/app/explore/start_page.dart';
import 'package:software/main.dart' as app;
import 'package:ubuntu_service/ubuntu_service.dart';

import '../test/test_utils.dart';
import 'integration_test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(resetAllServices);

  group('Package Installer App', () {
    testWidgets('Install and remove local deb', (tester) async {
      final installedFile = File('/usr/bin/hello');

      final localDeb =
          File('integration_test/assets/hello_2.10-2ubuntu4_amd64.deb');
      expect(localDeb.existsSync(), isTrue);

      initCustomExpect();

      await app.main([localDeb.absolute.path]);
      await tester.pumpUntil(
        find.byType(PackagePage),
        timeout: const Duration(seconds: 80),
      );
      await tester.pumpAndSettle();

      await testInstallPackage(tester, installedFile: installedFile);
      await testRemovePackage(tester, installedFile: installedFile);
    });

    testWidgets('Install and remove snap', (tester) async {
      final installedFile = File('/snap/bin/hello');
      const packageName = 'hello';

      initCustomExpect();

      await app.main([]);
      await tester.pumpUntil(
        find.byType(StartPage),
        timeout: const Duration(seconds: 80),
      );
      await tester.pumpAndSettle();

      await testSearchPackage(tester, packageName: packageName);
      await testInstallPackage(tester, installedFile: installedFile);
      await testRemovePackage(tester, installedFile: installedFile);
    });

    testWidgets('Install and remove snap from url', (tester) async {
      final installedFile = File('/snap/bin/hello');

      initCustomExpect();

      await app.main(['snap://hello']);
      await tester.pumpUntil(
        find.byType(SnapPage),
        timeout: const Duration(seconds: 80),
      );
      await tester.pumpAndSettle();

      await testInstallPackage(tester, installedFile: installedFile);
      await testRemovePackage(tester, installedFile: installedFile);
    });
  });
}

Future<void> testSearchPackage(
  WidgetTester tester, {
  required String packageName,
}) async {
  final searchField = find.widgetWithText(SearchField, tester.lang.searchHint);
  expectSync(searchField, findsOneWidget);
  await tester.enterText(searchField, packageName);
  await tester.pumpAndSettle();

  final helloBanner = find.widgetWithText(AppBanner, packageName);
  expectSync(helloBanner, findsOneWidget);

  await tester.tap(helloBanner);
  await tester.pumpAndSettle();
}

Future<void> testInstallPackage(
  WidgetTester tester, {
  required File installedFile,
}) async {
  expect(installedFile.existsSync(), isFalse);

  final enabledInstallButton = find.ancestor(
    of: find.text(tester.lang.install),
    matching: find.byWidgetPredicate(
      (widget) => widget is ElevatedButton && widget.enabled,
    ),
  );
  final enabledRemoveButton = find.ancestor(
    of: find.text(tester.lang.remove),
    matching: find.byWidgetPredicate(
      (widget) => widget is OutlinedButton && widget.enabled,
    ),
  );
  expectSync(enabledInstallButton, findsOneWidget);
  expectSync(enabledRemoveButton, findsNothing);

  await tester.tap(enabledInstallButton);
  await tester.pumpUntil(enabledRemoveButton);

  expectSync(enabledRemoveButton, findsOneWidget);
  expectSync(enabledInstallButton, findsNothing);

  expectSync(installedFile.existsSync(), isTrue);
}

Future<void> testRemovePackage(
  WidgetTester tester, {
  required File installedFile,
}) async {
  expectSync(installedFile.existsSync(), isTrue);

  final enabledInstallButton = find.ancestor(
    of: find.text(tester.lang.install),
    matching: find.byWidgetPredicate(
      (widget) => widget is ElevatedButton && widget.enabled,
    ),
  );
  final enabledRemoveButton = find.ancestor(
    of: find.text(tester.lang.remove),
    matching: find.byWidgetPredicate(
      (widget) => widget is OutlinedButton && widget.enabled,
    ),
  );
  expect(enabledInstallButton, findsNothing);
  expect(enabledRemoveButton, findsOneWidget);

  await tester.tap(enabledRemoveButton);
  await tester.pumpUntil(enabledInstallButton);

  expect(enabledInstallButton, findsOneWidget);
  expect(enabledRemoveButton, findsNothing);

  expect(installedFile.existsSync(), isFalse);
}
