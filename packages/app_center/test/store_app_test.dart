import 'dart:async';

import 'package:app_center/error/error_l10n.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/store/store_providers.dart';
import 'package:app_center/store/store_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  group('font fallbacks', () {
    test('prefers the active CJK locale', () {
      for (final testCase in [
        (locale: const Locale('ja'), expected: 'Noto Sans CJK JP'),
        (locale: const Locale('ko'), expected: 'Noto Sans CJK KR'),
        (locale: const Locale('zh'), expected: 'Noto Sans CJK SC'),
        (locale: const Locale('zh', 'TW'), expected: 'Noto Sans CJK TC'),
        (locale: const Locale('zh', 'HK'), expected: 'Noto Sans CJK HK'),
        (
          locale: const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
          ),
          expected: 'Noto Sans CJK TC',
        ),
      ]) {
        final theme = yaruLight.customize(locale: testCase.locale);

        expect(
          theme.textTheme.bodyMedium!.fontFamilyFallback!.first,
          testCase.expected,
        );
      }
    });

    test('applies to Yaru component text styles', () {
      final theme = yaruLight.customize(locale: const Locale('ja'));
      final fallback = theme.textTheme.bodyMedium!.fontFamilyFallback;
      final inputTheme = theme.inputDecorationTheme;
      final dropdownInputTheme = theme.dropdownMenuTheme.inputDecorationTheme!;

      expect(
        _textStylesOf(theme.textTheme).map((style) => style.fontFamilyFallback),
        everyElement(fallback),
      );
      expect(
        _textStylesOf(
          theme.primaryTextTheme,
        ).map((style) => style.fontFamilyFallback),
        everyElement(fallback),
      );
      expect(theme.appBarTheme.titleTextStyle!.fontFamilyFallback, fallback);
      expect(theme.listTileTheme.titleTextStyle!.fontFamilyFallback, fallback);
      expect(
        theme.listTileTheme.subtitleTextStyle!.fontFamilyFallback,
        fallback,
      );
      expect(theme.chipTheme.labelStyle!.fontFamilyFallback, fallback);
      expect(
        theme.chipTheme.secondaryLabelStyle!.fontFamilyFallback,
        fallback,
      );
      expect(
        theme.menuButtonTheme.style!.textStyle!.resolve({})!.fontFamilyFallback,
        fallback,
      );
      expect(
        theme.snackBarTheme.contentTextStyle!.fontFamilyFallback,
        fallback,
      );
      expect(
        _textStylesOf(inputTheme).map((style) => style.fontFamilyFallback),
        everyElement(fallback),
      );
      expect(
        _textStylesOf(
          dropdownInputTheme,
        ).map((style) => style.fontFamilyFallback),
        everyElement(fallback),
      );
    });
  });

  group('updates badge', () {
    testWidgets('no updates available', (tester) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      registerMockSnapdService();
      await tester.pumpApp(
        (_) => const ProviderScope(
          child: StoreApp(),
        ),
      );
      await tester.pump();

      final manageTile = find.widgetWithText(
        YaruMasterTile,
        tester.l10n.managePageLabel,
      );
      final badge = find.descendant(
        of: manageTile,
        matching: find.byType(Badge),
      );
      expect(badge, findsNothing);
    });

    testWidgets('updates available', (tester) async {
      final snaps = [
        createSnap(name: 'firefox'),
        createSnap(name: 'thunderbird'),
      ];
      registerMockSnapdService(
        refreshableSnaps: snaps,
        installedSnaps: snaps,
      );
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      await tester.pumpApp(
        (_) => const ProviderScope(
          child: StoreApp(),
        ),
      );
      await tester.pump();

      final manageTile = find.widgetWithText(
        YaruMasterTile,
        tester.l10n.managePageLabel,
      );
      final badge = find.descendant(
        of: manageTile,
        matching: find.byType(Badge),
      );
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

        final exception = SnapdException(
          kind: 'error kind',
          message: 'error message',
        );
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

    group('showing error from error stream', () {
      for (final testCase in [
        (
          name: 'generic snapd exception',
          error: SnapdException(message: 'error message', kind: 'error kind'),
          expectDialog: true,
        ),
        (
          name: 'auth-cancelled error',
          error: SnapdException(message: 'cancelled', kind: 'auth-cancelled'),
          expectDialog: false,
        ),
        (
          name: 'PackageKit transaction error',
          error: PackageKitTransactionError('Transaction 1 was destroyed'),
          expectDialog: true,
        ),
        (
          name: 'PackageKit service error',
          error: const PackageKitServiceError(
            code: PackageKitError.packageNotFound,
            details: 'not available as an update candidate',
          ),
          expectDialog: true,
        ),
        (
          name: 'PackageKit transaction cancelled',
          error: PackageKitTransactionCancelled('Transaction 1 was cancelled'),
          expectDialog: false,
        ),
        (
          /* The stream is typed Object; unknown values must be ignored
             rather than crash the listener. */
          name: 'unknown error object',
          error: 'not an exception',
          expectDialog: false,
        ),
      ]) {
        testWidgets(testCase.name, (tester) async {
          registerMockSnapdService();
          registerMockService<GtkApplicationNotifier>(
            createMockGtkApplicationNotifier(),
          );
          await tester.pumpApp(
            (_) => ProviderScope(
              overrides: [
                errorStreamProvider.overrideWith(
                  (ref) => Stream.value(testCase.error),
                ),
              ],
              child: const StoreApp(),
            ),
          );
          await tester.pump();

          expect(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.text(
                ErrorMessage.fromObject(testCase.error).body(tester.l10n),
              ),
            ),
            testCase.expectDialog ? findsOneWidget : findsNothing,
          );
        });
      }
    });

    testWidgets('routes to snap with channel', (tester) async {
      final storeSnap = createSnap(
        name: 'testsnap',
        channels: {
          'latest/stable': SnapChannel(
            confinement: SnapConfinement.strict,
            size: 1337,
            releasedAt: DateTime(1970),
            version: '1.0.0',
          ),
          'latest/edge': SnapChannel(
            confinement: SnapConfinement.strict,
            size: 1337,
            releasedAt: DateTime(1970),
            version: '2.0.0',
          ),
        },
      );
      registerMockSnapdService(
        storeSnap: storeSnap,
      );
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());

      final container = createContainer(
        overrides: [
          initialRouteProvider.overrideWithValue(
            StoreRoutes.namedSnap(name: 'testsnap', channel: 'latest/edge'),
          ),
        ],
      );

      await tester.pumpApp(
        (_) => UncontrolledProviderScope(
          container: container,
          child: const StoreApp(),
        ),
      );
      await tester.pumpAndSettle();

      final snapData = await container.read(
        snapModelProvider('testsnap').future,
      );
      expect(snapData.selectedChannel, equals('latest/edge'));
    });
  });
}

Iterable<TextStyle> _textStylesOf(Object theme) => switch (theme) {
  TextTheme() => [
    theme.displayLarge!,
    theme.displayMedium!,
    theme.displaySmall!,
    theme.headlineLarge!,
    theme.headlineMedium!,
    theme.headlineSmall!,
    theme.titleLarge!,
    theme.titleMedium!,
    theme.titleSmall!,
    theme.bodyLarge!,
    theme.bodyMedium!,
    theme.bodySmall!,
    theme.labelLarge!,
    theme.labelMedium!,
    theme.labelSmall!,
  ],
  InputDecorationThemeData() => [
    theme.errorStyle!,
    theme.helperStyle!,
    theme.hintStyle!,
    theme.labelStyle!,
    theme.prefixStyle!,
    theme.suffixStyle!,
  ],
  _ => throw ArgumentError.value(theme),
};
