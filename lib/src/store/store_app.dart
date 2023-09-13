import 'package:flutter/material.dart' hide AboutDialog, showAboutDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/detail.dart';
import '/l10n.dart';
import '/layout.dart';
import '/search.dart';
import 'store_navigator.dart';
import 'store_observer.dart';
import 'store_pages.dart';
import 'store_providers.dart';
import 'store_routes.dart';

@internal
final log = Logger('store_app');

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
        theme: yaru.theme,
        darkTheme: yaru.darkTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        home: Scaffold(
          appBar: YaruWindowTitleBar(
            title: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kSearchBarWidth),
              child: SearchField(
                onSearch: (query) =>
                    _navigator.pushAndRemoveSearch(query: query),
                onSnapSelected: (name) => _navigator.pushDetail(name: name),
                onDebSelected: (_) {
                  log.debug('Detail page for debs not implemented yet!');
                }, // TODO: push detail page
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
              StoreRoutes.detail => MaterialPageRoute(
                  settings: settings,
                  builder: (_) => DetailPage(
                    snapName: StoreRoutes.detailOf(settings)!,
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
