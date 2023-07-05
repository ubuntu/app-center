import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'category.dart';
import 'detail.dart';
import 'explore.dart';
import 'l10n.dart';
import 'manage.dart';
import 'routes.dart';
import 'search.dart';
import 'snapd.dart';

typedef StorePage = ({
  IconData icon,
  String Function(BuildContext) labelBuilder,
  WidgetBuilder builder
});

class StoreApp extends StatefulWidget {
  const StoreApp({super.key});

  @override
  State<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends State<StoreApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    final gtkApp = getService<GtkApplicationNotifier>();
    gtkApp.addCommandLineListener(_handleCommandLine);
    _handleCommandLine(gtkApp.commandLine!);
  }

  @override
  void dispose() {
    final gtkApp = getService<GtkApplicationNotifier>();
    gtkApp.removeCommandLineListener(_handleCommandLine);
    super.dispose();
  }

  Future<void> _handleCommandLine(List<String> args) async {
    if (args.length == 1) {
      final snapd = getService<SnapdService>();
      final result = await snapd.find(name: args.single);
      if (result.isNotEmpty) {
        await _navigatorKey.currentState!.pushNamed(
          Routes.detail,
          arguments: result.first,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <StorePage>[
      (
        icon: ExplorePage.icon,
        labelBuilder: ExplorePage.label,
        builder: (_) => const ExplorePage(),
      ),
      (
        icon: ProductivityPage.icon,
        labelBuilder: ProductivityPage.label,
        builder: (_) => const ProductivityPage(),
      ),
      (
        icon: DevelopmentPage.icon,
        labelBuilder: DevelopmentPage.label,
        builder: (_) => const DevelopmentPage(),
      ),
      (
        icon: GamesPage.icon,
        labelBuilder: GamesPage.label,
        builder: (_) => const GamesPage(),
      ),
      (
        icon: ManagePage.icon,
        labelBuilder: ManagePage.label,
        builder: (_) => const ManagePage(),
      ),
    ];
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
                  _navigatorKey.currentState!.pushNamedAndRemoveUntil(
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
            length: pages.length,
            itemBuilder: (context, index, selected) => YaruNavigationRailItem(
              icon: Icon(pages[index].icon),
              label: Text(pages[index].labelBuilder(context)),
              style: YaruNavigationRailStyle.labelled,
            ),
            pageBuilder: (context, index) => pages[index].builder(context),
            onGenerateRoute: (settings) => switch (settings.name) {
              Routes.detail => MaterialPageRoute(
                  settings: settings,
                  builder: (_) => DetailPage(snap: settings.arguments as Snap),
                ),
              Routes.search => MaterialPageRoute(
                  settings: settings,
                  builder: (_) =>
                      SearchPage(query: settings.arguments as String),
                ),
              _ => null,
            },
          ),
        ),
      ),
    );
  }
}
