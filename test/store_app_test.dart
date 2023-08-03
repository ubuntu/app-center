import 'package:app_store/snapd.dart';
import 'package:app_store/src/store/store_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/widgets.dart';

import 'test_utils.dart';

void main() {
  group('updates badge', () {
    testWidgets('no updates available', (tester) async {
      registerMockService<GtkApplicationNotifier>(
          createMockGtkApplicationNotifier());
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            updatesProvider.overrideWith((ref) => createMockUpdatesModel())
          ],
          child: const StoreApp(),
        ),
      );
      await tester.pump();

      final manageTile =
          find.widgetWithText(YaruMasterTile, tester.l10n.managePageLabel);
      final badge =
          find.descendant(of: manageTile, matching: find.byType(Badge));
      expect(badge, findsNothing);
    });

    testWidgets('updates available', (tester) async {
      registerMockService<GtkApplicationNotifier>(
          createMockGtkApplicationNotifier());
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            updatesProvider.overrideWith((ref) => createMockUpdatesModel(
                refreshableSnapNames: ['firefox', 'thunderbird']))
          ],
          child: const StoreApp(),
        ),
      );
      await tester.pump();

      final manageTile =
          find.widgetWithText(YaruMasterTile, tester.l10n.managePageLabel);
      final badge =
          find.descendant(of: manageTile, matching: find.byType(Badge));
      expect(badge, findsOneWidget);
      expect((tester.widget<Badge>(badge).label! as Text).data, equals('2'));
    });
  });
}
