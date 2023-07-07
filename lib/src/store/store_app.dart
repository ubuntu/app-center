import 'package:flutter/material.dart' hide AboutDialog, showAboutDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/about.dart';
import '/detail.dart';
import '/l10n.dart';
import '/routes.dart';
import '/search.dart';
import 'store_pages.dart';
import 'store_providers.dart';

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
                onSearch: (query) {
                  _navigator.pushNamedAndRemoveUntil(
                    Routes.search,
                    (route) => route.settings.name != Routes.search,
                    arguments: query,
                  );
                },
              ),
            ),
          ),
          body: YaruNavigationPage(
            navigatorKey: _navigatorKey,
            initialRoute: ref.watch(initialRouteProvider),
            length: pages.length,
            itemBuilder: (context, index, selected) => YaruNavigationRailItem(
              icon: Icon(pages[index].icon),
              label: Text(pages[index].labelBuilder(context)),
              style: YaruNavigationRailStyle.labelled,
            ),
            pageBuilder: (context, index) => pages[index].builder(context),
            onGenerateRoute: (settings) => switch (settings.name) {
              final String route when Routes.isDetail(route) =>
                MaterialPageRoute(
                  settings: settings,
                  builder: (_) => DetailPage(
                    snapName: Routes.getArgument(route, 'snap') ??
                        settings.arguments as String,
                  ),
                ),
              final String route when Routes.isSearch(route) =>
                MaterialPageRoute(
                  settings: settings,
                  builder: (_) => SearchPage(
                    query: Routes.getArgument(route, 'query') ??
                        settings.arguments as String,
                  ),
                ),
              _ => null,
            },
            trailing: Builder(
              builder: (context) => YaruNavigationRailItem(
                icon: Icon(AboutDialog.icon),
                label: Text(AboutDialog.label(context)),
                style: YaruNavigationRailStyle.labelled,
                onTap: () => showAboutDialog(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
