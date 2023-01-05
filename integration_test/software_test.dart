import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/main.dart' as app;
import 'package:ubuntu_service/ubuntu_service.dart';

import 'integration_test_utils.dart';
import '../test/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(resetAllServices);

  group('Package Installer App', () {
    testWidgets('Install local deb', (tester) async {
      final localDeb =
          File('integration_test/assets/hello_2.10-2ubuntu4_amd64.deb');
      expect(localDeb.existsSync(), isTrue);

      final helloExe = File('/usr/bin/hello');
      expect(helloExe.existsSync(), isFalse);
      initCustomExpect();
      await app.main([localDeb.absolute.path]);
      await tester.pumpUntil(
        find.byWidgetPredicate((widget) => widget is PackagePage),
        timeout: const Duration(seconds: 80),
      );
      await tester.pumpAndSettle();

      final installButton =
          find.widgetWithText(ElevatedButton, tester.lang.install);
      expectSync(installButton, findsOneWidget);
      await tester.tap(installButton);

      final enabledUninstallButton = find.ancestor(
        of: find.text(tester.lang.remove),
        matching: find.byWidgetPredicate(
          (widget) => widget is OutlinedButton && widget.enabled,
        ),
      );
      await tester.pumpUntil(enabledUninstallButton);

      final uninstallButton =
          find.widgetWithText(OutlinedButton, tester.lang.remove);

      expectSync(uninstallButton, findsOneWidget);
      expectSync(installButton, findsNothing);

      expectSync(helloExe.existsSync(), isTrue);

      await tester.tap(uninstallButton);
      await tester.pumpUntil(uninstallButton, present: false);

      expect(installButton, findsOneWidget);
      expect(uninstallButton, findsNothing);

      expect(helloExe.existsSync(), isFalse);
    });
  });
}
