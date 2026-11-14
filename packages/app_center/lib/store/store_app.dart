import 'dart:async';
import 'dart:ui';

import 'package:app_center/addons/addons.dart';
import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/unified_app_page.dart';
import 'package:app_center/deb/deb.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/games/games.dart';
import 'package:app_center/gstreamer/gstreamer.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/manage_page.dart';
import 'package:app_center/media_support/media_support.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/search/search.dart';
import 'package:app_center/snapd/seen_snaps_model.dart';
import 'package:app_center/snapd/snap_model.dart';
import 'package:app_center/snapd/snap_page.dart';
import 'package:app_center/store/store_navigator.dart';
import 'package:app_center/store/store_observer.dart';
import 'package:app_center/store/store_pages.dart';
import 'package:app_center/store/store_providers.dart';
import 'package:app_center/store/store_routes.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/gestures.dart' show kBackMouseButton;
import 'package:flutter/material.dart' hide AboutDialog, showAboutDialog;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

// Making a provider to provide navigatorKeyTwo
final materialAppNavigatorKeyProvider = Provider(
  (ref) => GlobalKey<NavigatorState>(),
);

final yaruPageControllerProvider = Provider(
  (ref) => YaruPageController(length: ref.watch(storePagesProvider).length),
);

final routeNameProvider = StateProvider<String?>((ref) => null);

final canGoBackProvider = Provider<bool>((ref) {
  final routeName = ref.watch(routeNameProvider);
  return routeName != null && routeName != '/';
});

class StoreApp extends ConsumerStatefulWidget {
  const StoreApp({super.key});

  @override
  ConsumerState<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends ConsumerState<StoreApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final searchFocus = FocusNode();
  late Locale _locale;

  NavigatorState get _navigator => _navigatorKey.currentState!;

  /// Seeds the install channel requested by a snap route (e.g. from a
  /// `snap://` URL with a `channel` parameter) before the snap page opens,
  /// so [SnapModel] can set up the requested channel from the start.
  ///
  /// Called only from lifecycle/listener callbacks ([initState] and the
  /// [routeStreamProvider] listener), never from `build`, so seeding is
  /// not a build-time side effect. A snap route without a channel clears
  /// any previously seeded value for that snap.
  ///
  /// The [initState] call is deferred to a post-frame callback: Riverpod
  /// forbids modifying a provider from `initState`, which runs inside
  /// the build scope. The callback runs right after the first frame,
  /// still before the snap page's data arrives, and [SnapModel] watches
  /// the provider, so the requested channel is picked up either way.
  void _seedInitialChannel(String? route) {
    if (route == null) return;
    final settings = RouteSettings(name: route);
    if (!StoreRoutes.isSnap(settings)) return;
    final snapName = StoreRoutes.snapOf(settings);
    if (snapName == null) return;
    ref.read(snapInitialChannelProvider(snapName).notifier).state =
        StoreRoutes.channelOf(settings);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons & kBackMouseButton == 0) return;
    final rootNavigator = ref
        .read(materialAppNavigatorKeyProvider)
        .currentState;
    if (rootNavigator?.canPop() ?? false) return;
    if (!ref.read(canGoBackProvider)) return;
    _navigator.maybePop();
  }

  @override
  void initState() {
    super.initState();
    // Created up front so it sees what the first searches return.
    ref.read(seenSnapsModelProvider);
    // Seed the install channel requested by the initial route (e.g. a
    // `snap://` URL) before the snap page opens, so `SnapModel` picks it
    // up as its initial selected channel. Only the write is deferred:
    // reading the route here is fine, but Riverpod forbids modifying a
    // provider from `initState` (see `_seedInitialChannel`).
    final initialRoute = ref.read(initialRouteProvider);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _seedInitialChannel(initialRoute),
    );
    WidgetsBinding.instance.addObserver(this);
    _locale = _resolveFontLocale(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    final locale = _resolveFontLocale(locales);
    if (locale != _locale) setState(() => _locale = locale);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(routeStreamProvider, (prev, next) {
      next.whenData((route) {
        _seedInitialChannel(route);
        _navigator.pushNamed(route);
      });
    });

    return Listener(
      onPointerDown: _handlePointerDown,
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
            searchFocus.requestFocus();
            searchFocus.nextFocus();
          },
          const SingleActivator(LogicalKeyboardKey.keyQ, control: true): () {
            unawaited(
              ServicesBinding.instance.exitApplication(AppExitType.cancelable),
            );
          },
        },
        child: YaruTheme(
          builder: (context, yaru, child) => MaterialApp(
            theme: yaru.theme.customize(locale: _locale),
            darkTheme: yaru.darkTheme.customize(locale: _locale),
            highContrastTheme: yaruHighContrastLight.customize(
              highContrast: true,
              locale: _locale,
            ),
            highContrastDarkTheme: yaruHighContrastDark.customize(
              highContrast: true,
              locale: _locale,
            ),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: localizationsDelegates,
            navigatorKey: ref.watch(materialAppNavigatorKeyProvider),
            supportedLocales: supportedLocales,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
                PointerDeviceKind.trackpad,
              },
            ),
            home: _StoreAppHome(
              navigatorKey: _navigatorKey,
              searchFocus: searchFocus,
            ),
          ),
        ),
      ),
    );
  }
}

Locale _resolveFontLocale(List<Locale>? preferredLocales) {
  final resolvedLocale = basicLocaleListResolution(
    preferredLocales,
    supportedLocales,
  );
  return preferredLocales
          ?.where(
            (locale) => locale.languageCode == resolvedLocale.languageCode,
          )
          .firstOrNull ??
      resolvedLocale;
}

class _StoreAppHome extends ConsumerWidget {
  const _StoreAppHome({required this.navigatorKey, required this.searchFocus});

  final GlobalKey<NavigatorState> navigatorKey;
  final FocusNode searchFocus;

  NavigatorState get navigator => navigatorKey.currentState!;

  Future<void> _showError(BuildContext context, Object e) {
    final errorMessage = ErrorMessage.fromObject(e);
    final title = errorMessage.title(AppLocalizations.of(context));
    final body = errorMessage.body(AppLocalizations.of(context));

    return showErrorDialog(
      context: context,
      title: title,
      message: body,
      type: errorMessage.type,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    YaruWindow.of(context).setTitle(l10n.appCenterLabel);

    final textScalar = MediaQuery.textScalerOf(context);

    ref.listen(errorStreamProvider, (_, error) {
      if (!error.hasValue) return;
      final value = error.value!;
      if (value is SnapdException) {
        // Don't show an error if the user cancelled the auth dialog.
        if (value.kind == 'auth-cancelled') {
          return;
        }
        _showError(context, value);
      } else if (value is PackageKitTransactionCancelled) {
        // User cancelled (e.g. dismissed the polkit dialog) — not an error.
        return;
      } else if (value is PackageKitServiceError) {
        // Same dialog as the old deb page.
        showErrorDialog(
          context: context,
          title: 'PackageKit error: ${value.code}',
          message: value.details,
        );
      } else if (value is PackageKitTransactionError) {
        _showError(context, value);
      }
    });

    final searchField = YaruWindowTitleBar(
      border: BorderSide.none,
      leading: _MaybeBackButton(navigatorKey),
      title: SizedBox(
        width: kSearchBarWidth,
        child: SearchField(
          onSearch: (query) => navigator.pushAndRemoveSearch(query: query),
          onSnapSelected: (name) => navigator.pushSnap(name: name),
          onDebSelected: (id) => navigator.pushDeb(id: id),
          searchFocus: searchFocus,
        ),
      ),
    );
    final unifiedDetailsEnabled = ref.watch(unifiedDetailsEnabledProvider);

    return Scaffold(
      body: YaruMasterDetailPage(
        navigatorKey: navigatorKey,
        navigatorObservers: [StoreObserver(ref)],
        initialRoute: ref.watch(initialRouteProvider),
        controller: ref.watch(yaruPageControllerProvider),
        tileBuilder: (context, index, selected, availableWidth) =>
            ref.watch(storePagesProvider)[index].tileBuilder(context, selected),
        pageBuilder: (context, index) => ref
            .watch(storePagesProvider)[index]
            .pageBuilder(context, searchField),
        paneLayoutDelegate: YaruResizablePaneDelegate(
          initialPaneSize: kPaneWidth * textScalar.scale(1),
          minPaneSize: kPaneWidth * textScalar.scale(1),
          minPageSize: kCardSizeWide.width + (kPagePadding * 2),
        ),
        appBar: YaruWindowTitleBar(
          title: Text(l10n.appCenterLabel),
          border: BorderSide.none,
          backgroundColor: YaruMasterDetailTheme.of(context).sideBarColor,
        ),
        breakpoint: 0, // always landscape
        onGenerateRoute: (settings) => switch (StoreRoutes.routeOf(settings)) {
          StoreRoutes.deb => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: searchField,
              body: unifiedDetailsEnabled
                  ? UnifiedAppPage(
                      entry: AppDetailsEntry.debComponent(
                        StoreRoutes.debOf(settings)!,
                      ),
                    )
                  : DebPage(id: StoreRoutes.debOf(settings)!),
            ),
          ),
          StoreRoutes.localDeb => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: searchField,
              body: LocalDebPage(path: StoreRoutes.localDebOf(settings)!),
            ),
          ),
          StoreRoutes.snap => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: searchField,
              body: unifiedDetailsEnabled
                  ? UnifiedAppPage(
                      entry: AppDetailsEntry.snap(
                        StoreRoutes.snapOf(settings)!,
                      ),
                    )
                  : SnapPage(snapName: StoreRoutes.snapOf(settings)!),
            ),
          ),
          StoreRoutes.search => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: searchField,
              body: SearchPage(
                query: StoreRoutes.queryOf(settings),
                category: StoreRoutes.categoryOf(settings),
              ),
            ),
          ),
          StoreRoutes.externalTools => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: searchField,
              body: const ExternalTools(),
            ),
          ),
          StoreRoutes.manage => MaterialPageRoute(
            settings: settings,
            builder: (_) =>
                YaruDetailPage(appBar: searchField, body: const ManagePage()),
          ),
          StoreRoutes.gstreamer => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: searchField,
              body: GStreamerPage(
                resources: StoreRoutes.gstResourcesOf(settings),
              ),
            ),
          ),
          StoreRoutes.additionalDrivers => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: YaruWindowTitleBar(
                border: BorderSide.none,
                leading: _MaybeBackButton(navigatorKey),
                title: Text(AdditionalDriversPage.label(context)),
              ),
              body: const AdditionalDriversPage(),
            ),
          ),
          StoreRoutes.addons => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: YaruWindowTitleBar(
                border: BorderSide.none,
                leading: _MaybeBackButton(navigatorKey),
                title: Text(AddonsPage.label(context)),
              ),
              body: const AddonsPage(),
            ),
          ),
          StoreRoutes.mediaSupport => MaterialPageRoute(
            settings: settings,
            builder: (_) => YaruDetailPage(
              appBar: YaruWindowTitleBar(
                border: BorderSide.none,
                leading: _MaybeBackButton(navigatorKey),
                title: Text(MediaSupportPage.label(context)),
              ),
              body: const MediaSupportPage(),
            ),
          ),
          _ => null,
        },
      ),
    );
  }
}

class _MaybeBackButton extends ConsumerWidget {
  const _MaybeBackButton(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPop = ref.watch(canGoBackProvider);
    return canPop
        ? YaruBackButton(
            style: YaruBackButtonStyle.rounded,
            onPressed: navigatorKey.currentState?.pop,
          )
        : const SizedBox();
  }
}

extension StoreAppThemeX on ThemeData {
  ThemeData customize({required Locale locale, bool highContrast = false}) {
    final cjkFallback = _cjkFallbackFor(locale);
    TextStyle? withFallback(TextStyle? style) =>
        style?.apply(fontFamilyFallback: cjkFallback);
    InputDecorationThemeData withInputFallback(
      InputDecorationThemeData theme,
    ) => theme.copyWith(
      labelStyle: withFallback(theme.labelStyle),
      floatingLabelStyle: withFallback(theme.floatingLabelStyle),
      helperStyle: withFallback(theme.helperStyle),
      hintStyle: withFallback(theme.hintStyle),
      errorStyle: withFallback(theme.errorStyle),
      prefixStyle: withFallback(theme.prefixStyle),
      suffixStyle: withFallback(theme.suffixStyle),
      counterStyle: withFallback(theme.counterStyle),
    );
    WidgetStateProperty<TextStyle?>? withStateFallback(
      WidgetStateProperty<TextStyle?>? style,
    ) => style == null
        ? null
        : WidgetStateProperty.resolveWith(
            (states) => withFallback(style.resolve(states)),
          );

    final base = copyWith(
      textTheme: textTheme.apply(fontFamilyFallback: cjkFallback),
      primaryTextTheme: primaryTextTheme.apply(fontFamilyFallback: cjkFallback),

      appBarTheme: appBarTheme.copyWith(
        toolbarTextStyle: withFallback(appBarTheme.toolbarTextStyle),
        titleTextStyle: withFallback(appBarTheme.titleTextStyle),
      ),

      navigationRailTheme: navigationRailTheme.copyWith(
        selectedLabelTextStyle: withFallback(
          navigationRailTheme.selectedLabelTextStyle,
        ),
        unselectedLabelTextStyle: withFallback(
          navigationRailTheme.unselectedLabelTextStyle,
        ),
      ),

      listTileTheme: listTileTheme.copyWith(
        titleTextStyle: withFallback(listTileTheme.titleTextStyle),
        subtitleTextStyle: withFallback(listTileTheme.subtitleTextStyle),
        leadingAndTrailingTextStyle: withFallback(
          listTileTheme.leadingAndTrailingTextStyle,
        ),
      ),

      chipTheme: chipTheme.copyWith(
        labelStyle: withFallback(chipTheme.labelStyle),
        secondaryLabelStyle: withFallback(chipTheme.secondaryLabelStyle),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: menuButtonTheme.style?.copyWith(
          textStyle: withStateFallback(menuButtonTheme.style?.textStyle),
        ),
      ),
      snackBarTheme: snackBarTheme.copyWith(
        contentTextStyle: withFallback(snackBarTheme.contentTextStyle),
      ),
      dropdownMenuTheme: dropdownMenuTheme.copyWith(
        textStyle: withFallback(dropdownMenuTheme.textStyle),
        inputDecorationTheme: dropdownMenuTheme.inputDecorationTheme == null
            ? null
            : withInputFallback(dropdownMenuTheme.inputDecorationTheme!),
      ),
      inputDecorationTheme: withInputFallback(inputDecorationTheme).copyWith(
        fillColor: colorScheme.surface,
        hoverColor: colorScheme.surface,
      ),
    );

    final highContrastTheme = base.copyWith(hintColor: colorScheme.onSurface);

    return highContrast ? highContrastTheme : base;
  }
}

List<String> _cjkFallbackFor(Locale locale) {
  const simplifiedChinese = 'Noto Sans CJK SC';
  const traditionalChinese = 'Noto Sans CJK TC';
  const hongKongChinese = 'Noto Sans CJK HK';
  const japanese = 'Noto Sans CJK JP';
  const korean = 'Noto Sans CJK KR';

  return switch ((locale.languageCode, locale.scriptCode, locale.countryCode)) {
    ('ja', _, _) => const [
      japanese,
      simplifiedChinese,
      traditionalChinese,
      hongKongChinese,
      korean,
    ],
    ('ko', _, _) => const [
      korean,
      simplifiedChinese,
      traditionalChinese,
      hongKongChinese,
      japanese,
    ],
    ('zh', _, 'HK') => const [
      hongKongChinese,
      traditionalChinese,
      simplifiedChinese,
      japanese,
      korean,
    ],
    ('zh', 'Hant', _) || ('zh', _, 'TW') => const [
      traditionalChinese,
      hongKongChinese,
      simplifiedChinese,
      japanese,
      korean,
    ],
    _ => const [
      simplifiedChinese,
      traditionalChinese,
      hongKongChinese,
      japanese,
      korean,
    ],
  };
}
