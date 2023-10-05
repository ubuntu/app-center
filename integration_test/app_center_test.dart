import 'dart:io';

import 'package:app_center/main.dart' as app;
import 'package:app_center/src/store/store_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ubuntu_test/ubuntu_test.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_test/yaru_test.dart';

import '../test/test_utils.dart';

void main() {
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
}

Future<void> testSearchSnap(
  WidgetTester tester, {
  required String packageName,
}) async {
  final searchField = find.textField(tester.l10n.searchFieldSearchHint);
  expectSync(searchField, findsOneWidget);
  await tester.enterText(searchField, packageName);
  await tester.pumpAndSettle();

  final dropdownEntry = find.widgetWithText(ListTile, packageName);
  await tester.pumpUntil(dropdownEntry);
  expectSync(dropdownEntry, findsOneWidget);

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
  expectSync(installButton, findsOneWidget);
  expectSync(openButton, findsNothing);

  await tester.tap(installButton);
  await tester.pumpUntil(openButton);

  expectSync(openButton, findsOneWidget);
  expectSync(installButton, findsNothing);

  expectSync(installedFile.existsSync(), isTrue);
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
