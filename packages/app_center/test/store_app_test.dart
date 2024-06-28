import 'dart:async';

import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  group('updates badge', () {
    testWidgets('no updates available', (tester) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            updatesModelProvider
                .overrideWith((ref) => createMockUpdatesModel()),
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
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            updatesModelProvider.overrideWith(
              (ref) => createMockUpdatesModel(
                refreshableSnapNames: ['firefox', 'thunderbird'],
              ),
            ),
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

  group('error handling', () {
    testWidgets(
      'errorStreamProvider receives exception when thrown',
      (tester) async {
        registerMockService<GtkApplicationNotifier>(
          createMockGtkApplicationNotifier(),
        );
        final snapdService = registerMockSnapdService();
        registerService<ErrorStreamController>(ErrorStreamController.new);

        final exception =
            SnapdException(kind: 'error kind', message: 'error message');
        when(snapdService.getSnap(any)).thenThrow(exception);

        final container = createContainer();
        unawaited(
          runZonedGuarded(
            () async {
              await tester.pumpApp(
                (_) => UncontrolledProviderScope(
                  container: container,
                  child: const StoreApp(),
                ),
              );
              await container.read(snapModelProvider('snapName').future);
            },
            (error, stackTrace) {
              if (error is Exception) {
                getService<ErrorStreamController>().add(error);
              }
            },
          ),
        );

        await expectLater(
          container.read(errorStreamProvider.future).asStream(),
          emits(exception),
        );
      },
    );

    testWidgets('showing error from error stream', (tester) async {
      registerMockSnapdService();
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            errorStreamProvider.overrideWith(
              (ref) => Stream.value(
                SnapdException(message: 'error message', kind: 'error kind'),
              ),
            ),
          ],
          child: const StoreApp(),
        ),
      );
      await tester.pump();

      expect(find.text('error message'), findsOneWidget);
      expect(find.text('error kind'), findsOneWidget);
    });
  });
}
