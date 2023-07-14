import 'package:flutter/material.dart' hide AboutDialog, showAboutDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/constants.dart';
import '/detail.dart';
import '/l10n.dart';
import '/search.dart';
import 'store_navigator.dart';
import 'store_observer.dart';
import 'store_pages.dart';
import 'store_providers.dart';
import 'store_routes.dart';

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
              constraints: const BoxConstraints(maxWidth: 400),
              child: SearchField(
                onSearch: (query) => _navigator.pushAndRemoveSearch(query),
                onSelected: (name) => _navigator.pushDetail(name),
              ),
            ),
          ),
          body: YaruNavigationPage(
            navigatorKey: _navigatorKey,
            navigatorObservers: [StoreObserver(ref)],
            initialRoute: ref.watch(initialRouteProvider),
            length: pages.length,
            itemBuilder: (context, index, selected) => YaruNavigationRailItem(
              icon: Icon(pages[index].icon(selected)),
              label: Text(pages[index].labelBuilder(context)),
              style: YaruNavigationRailStyle.labelledExtended,
              width: kNaviRailWidth,
            ),
            pageBuilder: (context, index) => pages[index].builder(context),
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
                    query: StoreRoutes.queryOf(settings)!,
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
