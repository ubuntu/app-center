import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:software/main.dart' as app;
import 'package:software/store_app/settings/settings_page.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../test/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Store App', () {
    group('Settings page', () {
      testWidgets('About dialog', (tester) async {
        app.main([]);
        await tester.pump();

        await tester
            .pumpAndTapNavigationRailButton(tester.lang.settingsPageTitle);

        final settingsPage = find.byType(SettingsPage);
        await tester.pumpUntil(settingsPage);
        expect(settingsPage, findsOneWidget);

        final aboutButton = find.text(tester.lang.about);
        await tester.pumpUntil(aboutButton);
        expect(aboutButton, findsOneWidget);
        await tester.tap(aboutButton);

        final aboutDialog = find.byType(AboutDialog);
        await tester.pumpUntil(aboutDialog);
        expect(aboutDialog, findsOneWidget);

        final closeButton = find.text(tester.materialLang.closeButtonLabel);
        await tester.pumpUntil(closeButton);
        expect(closeButton, findsOneWidget);
        await tester.tap(closeButton);
        await tester.pumpUntil(aboutDialog, reverse: true);

        expect(aboutDialog, findsNothing);
      });
    });
  });

  group('Package Installer App', () {
    testWidgets('Install local deb', (tester) async {
      final localDeb =
          File('integration_test/assets/hello_2.10-2ubuntu4_amd64.deb');
      expect(localDeb.existsSync(), isTrue);

      final helloExe = File('/usr/bin/hello');
      expect(helloExe.existsSync(), isFalse);

      const packageName = 'hello';
      const packageVersion = '2.10-2ubuntu4';
      const packageArchitecture = 'amd64';
      const packageLicense = 'unknown';
      const packageUninstalledSize = '25.98 KB';
      const packageInstalledSize = '108.00 KB';

      app.main([localDeb.absolute.path]);
      await tester.pump();

      Future<void> matchField(
        String label,
        String value, {
        bool exact = true,
      }) async {
        final tile = find.widgetWithText(YaruTile, label);
        await tester.pumpUntil(tile);
        expect(tile, findsOneWidget);
        final valueText = find.descendant(
          of: tile,
          matching: exact ? find.text(value) : find.textContaining(value),
        );
        await tester.pumpUntil(valueText);
        expect(valueText, findsOneWidget);
      }

      await matchField(tester.lang.name, packageName);
      await matchField(tester.lang.version, packageVersion);
      await matchField(tester.lang.architecture, packageArchitecture);
      await matchField(tester.lang.license, packageLicense);
      await matchField(tester.lang.size, packageUninstalledSize);

      final installButton = find.text(tester.lang.install);
      await tester.pumpUntil(installButton);
      expect(installButton, findsOneWidget);
      await tester.tap(installButton);

      final uninstallButton = find.text(tester.lang.remove);
      await tester.pumpUntil(uninstallButton);
      expect(uninstallButton, findsOneWidget);
      expect(installButton, findsNothing);

      expect(helloExe.existsSync(), isTrue);
      await matchField(tester.lang.size, packageInstalledSize);

      await tester.tap(uninstallButton);

      await tester.pumpUntil(installButton);
      expect(installButton, findsOneWidget);
      expect(uninstallButton, findsNothing);

      expect(helloExe.existsSync(), isFalse);
      await matchField(tester.lang.size, packageUninstalledSize);
    });
  });
}

extension IntegrationTester on WidgetTester {
  Future<void> pumpAndTapNavigationRailButton(String text) async {
    final navigationRail = find.byType(YaruNavigationRail);
    await pumpUntil(navigationRail);

    final button =
        find.descendant(of: navigationRail, matching: find.text(text));
    await pumpUntil(button);
    expect(button, findsOneWidget);

    return tap(button);
  }
}
