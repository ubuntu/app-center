import 'dart:async';
import 'dart:ui';

import 'package:app_center/error/error_l10n.dart';
import 'package:app_center/manage/snap_updates_model.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/search/search_field.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/store/store_pages.dart';
import 'package:app_center/store/store_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

void main() {
  final binding = TestAppBinding();
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

  group('Add-ons tab', () {
    testWidgets('shown when drivers are available', (tester) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      registerMockSnapdService();
      registerMockDriversService();
      await tester.pumpApp(
        (_) => const ProviderScope(
          child: StoreApp(),
        ),
      );
      await tester.pump();

      expect(
        find.widgetWithText(YaruMasterTile, tester.l10n.addonsPageLabel),
        findsOneWidget,
      );
    });

    testWidgets('shown when drivers are unavailable', (tester) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      registerMockSnapdService();
      registerMockDriversService(available: false);
      await tester.pumpApp(
        (_) => const ProviderScope(
          child: StoreApp(),
        ),
      );
      await tester.pump();

      expect(
        find.widgetWithText(YaruMasterTile, tester.l10n.addonsPageLabel),
        findsOneWidget,
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
      registerMockDriversService();
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
      registerMockDriversService();
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
        registerMockDriversService();

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
          registerMockDriversService();
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

      testWidgets('PackageKit service error shows its code and details', (
        tester,
      ) async {
        const error = PackageKitServiceError(
          code: PackageKitError.packageNotFound,
          details: 'not available as an update candidate',
        );
        registerMockSnapdService();
        registerMockService<GtkApplicationNotifier>(
          createMockGtkApplicationNotifier(),
        );
        registerMockDriversService();
        await tester.pumpApp(
          (_) => ProviderScope(
            overrides: [
              errorStreamProvider.overrideWith(
                (ref) => Stream.value(error),
              ),
            ],
            child: const StoreApp(),
          ),
        );
        await tester.pump();

        final dialog = find.byType(AlertDialog);
        expect(
          find.descendant(
            of: dialog,
            matching: find.text('PackageKit error: ${error.code}'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: dialog, matching: find.text(error.details)),
          findsOneWidget,
        );
      });
    });
  });

  group('shortcuts', () {
    testWidgets('search field requests focus when Control+F is pressed', (
      tester,
    ) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      registerMockSnapdService();
      registerMockDriversService();
      await tester.pumpApp(
        (_) => const ProviderScope(
          child: StoreApp(),
        ),
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      await tester.pump(const Duration(milliseconds: 100));

      final textFieldFinder = find.byType(SearchField);

      expect(textFieldFinder, findsOneWidget);

      final textField = tester.widget<SearchField>(textFieldFinder);
      final focusNode = textField.searchFocus;

      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('Control+F focuses the search field of a detail page', (
      tester,
    ) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      registerMockSnapdService();
      registerMockDriversService();
      await tester.pumpWidget(const ProviderScope(child: StoreApp()));
      final pagesNavigator = tester.state<NavigatorState>(
        find.descendant(
          of: find.byType(YaruMasterDetailPage),
          matching: find.byType(Navigator),
        ),
      );
      unawaited(pagesNavigator.pushNamed(StoreRoutes.manage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump(const Duration(milliseconds: 100));

      final focusedContext = FocusManager.instance.primaryFocus!.context!;
      expect(
        focusedContext.findAncestorWidgetOfExactType<SearchField>(),
        isNotNull,
      );
      expect(ModalRoute.isCurrentOf(focusedContext), isTrue);
    });

    testWidgets('requests app exit when Control+Q is pressed', (tester) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      registerMockSnapdService();
      registerMockDriversService();

      await tester.pumpWidget(
        const ProviderScope(
          child: StoreApp(),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyQ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyQ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      await tester.pump();
      expect(
        binding.requestedExitType,
        AppExitType.cancelable,
      );

      expect(
        binding.requestedExitCode,
        0,
      );
    });

    group('refresh', () {
      Future<(MockSnapdService, ProviderContainer)> pumpStoreApp(
        WidgetTester tester, {
        List<Override> overrides = const [],
        bool showManage = true,
      }) async {
        registerMockService<GtkApplicationNotifier>(
          createMockGtkApplicationNotifier(),
        );
        registerMockService<RatingsService>(registerMockRatingsService());
        final snapd = registerMockSnapdService();
        registerMockDriversService();
        final container = createContainer(overrides: overrides);

        await tester.pumpApp(
          (_) => UncontrolledProviderScope(
            container: container,
            child: const StoreApp(),
          ),
        );
        if (showManage) {
          container.read(yaruPageControllerProvider).index = container
              .read(storePagesProvider)
              .indexWhere((page) => page.route == StoreRoutes.manage);
        }
        await tester.pump(const Duration(milliseconds: 500));
        clearInteractions(snapd);
        return (snapd, container);
      }

      for (final keys in [
        [LogicalKeyboardKey.f5],
        [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyR],
      ]) {
        testWidgets('${keys.last.keyLabel} refetches the Manage page data', (
          tester,
        ) async {
          final (snapd, _) = await pumpStoreApp(tester);

          for (final key in keys) {
            await tester.sendKeyDownEvent(key);
          }
          for (final key in keys.reversed) {
            await tester.sendKeyUpEvent(key);
          }
          await tester.pump();

          verify(snapd.find(filter: SnapFindFilter.refresh)).called(1);
          verify(snapd.getSnaps()).called(1);
        });
      }

      testWidgets('F5 does nothing outside the Manage page', (tester) async {
        final (snapd, _) = await pumpStoreApp(tester, showManage: false);

        await tester.sendKeyEvent(LogicalKeyboardKey.f5);
        await tester.pump();

        verifyNever(snapd.find(filter: SnapFindFilter.refresh));
      });

      testWidgets('F5 is ignored while updating all', (tester) async {
        final (snapd, _) = await pumpStoreApp(
          tester,
          overrides: [
            currentlyRefreshAllSnapsProvider.overrideWith((_) => ['firefox']),
          ],
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.f5);
        await tester.pump();

        verifyNever(snapd.find(filter: SnapFindFilter.refresh));
      });

      testWidgets('F5 does nothing on a search opened from Manage', (
        tester,
      ) async {
        final (snapd, container) = await pumpStoreApp(tester);
        final pagesNavigator = tester.state<NavigatorState>(
          find.descendant(
            of: find.byType(YaruMasterDetailPage),
            matching: find.byType(Navigator),
          ),
        );
        for (final query in ['a', 'b']) {
          final name = StoreRoutes.namedSearch(query: query);
          // Same navigation as pushAndRemoveSearch, without the real page.
          unawaited(
            pagesNavigator.pushAndRemoveUntil(
              MaterialPageRoute<void>(
                settings: RouteSettings(name: name),
                builder: (_) => Text(name),
              ),
              (route) => !StoreRoutes.isSearch(route.settings),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        }

        await tester.sendKeyEvent(LogicalKeyboardKey.f5);
        await tester.pump();

        expect(
          container.read(routeNameProvider),
          StoreRoutes.namedSearch(query: 'b'),
        );
        verifyNever(snapd.find(filter: SnapFindFilter.refresh));
      });
    });
  });

  group('mouse back button', () {
    Future<void> pumpWithTestPage(WidgetTester tester) async {
      registerMockService<GtkApplicationNotifier>(
        createMockGtkApplicationNotifier(),
      );
      registerMockService<RatingsService>(registerMockRatingsService());
      registerMockSnapdService();
      registerMockDriversService();

      // No outer MaterialApp, so showDialog targets the app's root navigator.
      await tester.pumpWidget(const ProviderScope(child: StoreApp()));
      final pagesNavigator = tester.state<NavigatorState>(
        find.descendant(
          of: find.byType(YaruMasterDetailPage),
          matching: find.byType(Navigator),
        ),
      );
      unawaited(
        pagesNavigator.push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/test'),
            builder: (_) => const Text('test page'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    Future<void> click(
      WidgetTester tester,
      Finder target, {
      required int buttons,
    }) async {
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
        buttons: buttons,
      );
      await gesture.down(tester.getCenter(target));
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('pops the current page', (tester) async {
      await pumpWithTestPage(tester);
      expect(find.text('test page'), findsOneWidget);

      await click(tester, find.text('test page'), buttons: kBackMouseButton);

      expect(find.text('test page'), findsNothing);
    });

    testWidgets('ignores other mouse buttons', (tester) async {
      await pumpWithTestPage(tester);

      await click(tester, find.text('test page'), buttons: kPrimaryButton);

      expect(find.text('test page'), findsOneWidget);
    });

    testWidgets('is ignored while a dialog is open', (tester) async {
      await pumpWithTestPage(tester);
      unawaited(
        showDialog<void>(
          context: tester.element(find.text('test page')),
          builder: (_) => const AlertDialog(content: Text('dialog')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await click(tester, find.text('dialog'), buttons: kBackMouseButton);

      expect(find.text('dialog'), findsOneWidget);
      expect(find.text('test page'), findsOneWidget);
    });
  });
}

class TestAppBinding extends AutomatedTestWidgetsFlutterBinding {
  AppExitType? requestedExitType;
  int? requestedExitCode;

  @override
  Future<AppExitResponse> exitApplication(
    AppExitType exitType, [
    int exitCode = 0,
  ]) async {
    requestedExitType = exitType;
    requestedExitCode = exitCode;

    return AppExitResponse.cancel;
  }
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
