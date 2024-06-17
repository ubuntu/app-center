import 'dart:io';

import 'package:app_center/main.dart' as app;
import 'package:app_center/src/store/store_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_test/ubuntu_test.dart';
import 'package:yaru/icons.dart';
import 'package:yaru_test/yaru_test.dart';

import '../test/test_utils.dart';

void main() {
  tearDown(resetAllServices);
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('install and remove a snap', (tester) async {
    final file = File('/snap/bin/hello');
    await app.main([]);
    await tester.pumpUntil(find.byType(StoreApp));
    await tester.pumpAndSettle();
    await testSearchSnap(tester, packageName: 'hello');
    await testInstallSnap(tester, installedFile: file);
    await testRemoveSnap(tester, installedFile: file);
  });

  testWidgets('install a local debian package', (tester) async {
    await app.main(['integration_test/assets/appcenter-testdeb_1.0_amd64.deb']);
    await tester.pumpUntil(find.byType(StoreApp));
    await tester.pumpAndSettle();
    expect(find.text('appcenter-testdeb'), findsOneWidget);
    expect(
      find.text('Minimal package for App Center integration tests'),
      findsOneWidget,
    );
    expect(
      find.text(
          'This is a minimal test package for App Center integration tests.'),
      findsOneWidget,
    );
    expect(
      find.text('https://example.com/appcenter-testdeb'),
      findsOneWidget,
    );

    await tester.tap(find.button(tester.l10n.snapActionInstallLabel));
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.button(tester.l10n.snapActionInstallLabel),
      ),
    );
    await tester.pumpAndSettle();

    final result = await Process.run('dpkg', ['-s', 'appcenter-testdeb']);
    expect(result.exitCode, isZero);
  });
}

Future<void> testSearchSnap(
  WidgetTester tester, {
  required String packageName,
}) async {
  final searchField = find.textField(tester.l10n.searchFieldSearchHint);
  expect(searchField, findsOneWidget);
  await tester.enterText(searchField, packageName);
  await tester.pumpAndSettle();

  final dropdownEntry = find.widgetWithText(ListTile, packageName);
  await tester.pumpUntil(dropdownEntry);
  expect(dropdownEntry, findsOneWidget);

  await tester.tap(dropdownEntry);
  await tester.pumpAndSettle();
}

Future<void> testInstallSnap(
  WidgetTester tester, {
  required File installedFile,
}) async {
  expect(installedFile.existsSync(), isFalse);

  final installButton = find.button(tester.l10n.snapActionInstallLabel);
  final openButton = find.button(tester.l10n.snapActionOpenLabel);
  expect(installButton, findsOneWidget);
  expect(openButton, findsNothing);

  await tester.tap(installButton);
  await tester.pumpUntil(openButton);

  expect(openButton, findsOneWidget);
  expect(installButton, findsNothing);

  expect(installedFile.existsSync(), isTrue);
}

Future<void> testRemoveSnap(
  WidgetTester tester, {
  required File installedFile,
}) async {
  final installButton = find.button(tester.l10n.snapActionInstallLabel);
  expect(installButton, findsNothing);

  await tester.tap(find.iconButton(YaruIcons.view_more_horizontal));
  await tester.pumpAndSettle();
  await tester.tap(find.button(tester.l10n.snapActionRemoveLabel));
  await tester.pumpUntil(installButton);

  expect(installedFile.existsSync(), isFalse);
}
