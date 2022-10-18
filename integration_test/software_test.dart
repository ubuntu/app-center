import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:software/main.dart' as app;
import 'package:software/store_app/settings/settings_page.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../test/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings page', () {
    testWidgets('About dialog', (tester) async {
      app.main([]);
      await tester.pumpAndSettle();

      await tester
          .pumpAndTapNavigationRailButton(tester.lang.settingsPageTitle);
      await tester.pumpAndSettle();

      final settingsPage = find.byType(SettingsPage);
      expect(settingsPage, findsOneWidget);
      await tester.pumpUntil(settingsPage);

      final aboutButton = find.text(tester.lang.about);
      expect(aboutButton, findsOneWidget);
      await tester.pumpUntil(aboutButton);
      await tester.tap(aboutButton);
      await tester.pumpAndSettle();

      final aboutDialog = find.byType(AboutDialog);
      expect(aboutDialog, findsOneWidget);
      await tester.pumpUntil(aboutDialog);

      final closeButton = find.text(tester.materialLang.closeButtonLabel);
      expect(closeButton, findsOneWidget);
      await tester.pumpUntil(closeButton);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(aboutDialog, findsNothing);
    });
  });
}

extension IntegrationTester on WidgetTester {
  Future<void> pumpAndTapNavigationRailButton(String text) async {
    final navigationRail = find.byType(YaruNavigationRail);
    await pumpUntil(navigationRail);

    final button =
        find.descendant(of: navigationRail, matching: find.text(text));
    expect(button, findsOneWidget);
    await pumpUntil(button);

    return tap(button);
  }
}
