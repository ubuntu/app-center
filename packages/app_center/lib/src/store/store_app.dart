import 'package:app_center/deb.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

// Making a provider to provide navigatorKeyTwo
final materialAppNavigatorKeyProvider =
    Provider((ref) => GlobalKey<NavigatorState>());

class StoreApp extends ConsumerStatefulWidget {
  const StoreApp({super.key});

  @override
  ConsumerState<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends ConsumerState<StoreApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    ref.listen(routeStreamProvider, (prev, next) {
      next.whenData((route) => _navigator.pushNamed(route));
    });

    return YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        theme: yaru.theme?.copyWith(scaffoldBackgroundColor: Colors.white),
        darkTheme: yaru.darkTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localizationsDelegates,
        navigatorKey: ref.watch(materialAppNavigatorKeyProvider),
        supportedLocales: supportedLocales,
        home: Scaffold(
          appBar: YaruWindowTitleBar(
            title: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kSearchBarWidth),
              child: SearchField(
                onSearch: (query) =>
                    _navigator.pushAndRemoveSearch(query: query),
                onSnapSelected: (name) => _navigator.pushSnap(name: name),
                onDebSelected: (id) => _navigator.pushDeb(id: id),
              ),
            ),
          ),
          body: YaruMasterDetailPage(
            navigatorKey: _navigatorKey,
            navigatorObservers: [StoreObserver(ref)],
            initialRoute: ref.watch(initialRouteProvider),
            length: pages.length,
            tileBuilder: (context, index, selected, availableWidth) =>
                pages[index].tileBuilder(context, selected),
            pageBuilder: (context, index) => pages[index].pageBuilder(context),
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
              _ => null,
            },
          ),
        ),
      ),
    );
  }
}
