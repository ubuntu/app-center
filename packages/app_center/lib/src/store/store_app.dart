import 'package:app_center/deb.dart';
import 'package:app_center/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/search.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/store/store_navigator.dart';
import 'package:app_center/src/store/store_observer.dart';
import 'package:app_center/src/store/store_pages.dart';
import 'package:app_center/src/store/store_providers.dart';
import 'package:app_center/src/store/store_routes.dart';
import 'package:flutter/material.dart' hide AboutDialog, showAboutDialog;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

// Making a provider to provide navigatorKeyTwo
final materialAppNavigatorKeyProvider =
    Provider((ref) => GlobalKey<NavigatorState>());

final yaruPageControllerProvider =
    Provider((ref) => YaruPageController(length: pages.length));

class StoreApp extends ConsumerStatefulWidget {
  const StoreApp({super.key});

  @override
  ConsumerState<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends ConsumerState<StoreApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final searchFocus = FocusNode();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    ref.listen(routeStreamProvider, (prev, next) {
      next.whenData((route) => _navigator.pushNamed(route));
    });

    return CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
              () {
            searchFocus.requestFocus();
            searchFocus.nextFocus();
          }
        },
        child: YaruTheme(
          builder: (context, yaru, child) => MaterialApp(
            theme: yaru.theme,
            darkTheme: yaru.darkTheme,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: localizationsDelegates,
            navigatorKey: ref.watch(materialAppNavigatorKeyProvider),
            supportedLocales: supportedLocales,
            home: YaruWindowTitleSetter(
              child: Scaffold(
                appBar: YaruWindowTitleBar(
                  title: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: kSearchBarWidth),
                    child: SearchField(
                      onSearch: (query) =>
                          _navigator.pushAndRemoveSearch(query: query),
                      onSnapSelected: (name) => _navigator.pushSnap(name: name),
                      onDebSelected: (id) => _navigator.pushDeb(id: id),
                      searchFocus: searchFocus,
                    ),
                  ),
                ),
                body: YaruMasterDetailPage(
                  navigatorKey: _navigatorKey,
                  navigatorObservers: [StoreObserver(ref)],
                  initialRoute: ref.watch(initialRouteProvider),
                  controller: ref.watch(yaruPageControllerProvider),
                  tileBuilder: (context, index, selected, availableWidth) =>
                      pages[index].tileBuilder(context, selected),
                  pageBuilder: (context, index) =>
                      pages[index].pageBuilder(context),
                  layoutDelegate: const YaruMasterFixedPaneDelegate(
                    paneWidth: kPaneWidth,
                  ),
                  breakpoint: 0, // always landscape
                  onGenerateRoute: (settings) =>
                      switch (StoreRoutes.routeOf(settings)) {
                    StoreRoutes.deb => MaterialPageRoute(
                        settings: settings,
                        builder: (_) => DebPage(
                              id: StoreRoutes.debOf(settings)!,
                            )),
                    StoreRoutes.snap => MaterialPageRoute(
                        settings: settings,
                        builder: (_) => SnapPage(
                          snapName: StoreRoutes.snapOf(settings)!,
                        ),
                      ),
                    StoreRoutes.search => MaterialPageRoute(
                        settings: settings,
                        builder: (_) => SearchPage(
                          query: StoreRoutes.queryOf(settings),
                          category: StoreRoutes.categoryOf(settings),
                        ),
                      ),
                    '/externalTools' => MaterialPageRoute(
                        settings: settings,
                        builder: (_) => const ExternalTools(),
                      ),
                    _ => null,
                  },
                ),
              ),
            ),
          ),
        ));
  }
}

class YaruWindowTitleSetter extends StatelessWidget {
  const YaruWindowTitleSetter({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    YaruWindow.of(context).setTitle(l10n.appCenterLabel);

    return child;
  }
}
