import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'categories.dart';
import 'detail.dart';
import 'manage.dart';
import 'routes.dart';
import 'snapd.dart';

Future<void> main() async {
  await YaruWindowTitleBar.ensureInitialized();

  final snapd = SnapdService();
  await snapd.loadAuthorization();
  registerServiceInstance(snapd);

  runApp(const ProviderScope(child: StoreApp()));
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  final pages = const [
    CategoryPage(category: 'featured'),
    ManagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        theme: yaru.theme,
        darkTheme: yaru.darkTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: const YaruWindowTitleBar(),
          body: YaruNavigationPage(
            length: pages.length,
            itemBuilder: (context, index, selected) =>
                const YaruNavigationRailItem(
              icon: SizedBox(width: 24, height: 24, child: Placeholder()),
              style: YaruNavigationRailStyle.compact,
            ),
            pageBuilder: (context, index) => pages[index],
            onGenerateRoute: (settings) => switch (settings.name) {
              Routes.detail => MaterialPageRoute(
                  builder: (_) => DetailPage(snap: settings.arguments as Snap),
                ),
              _ => null,
            },
          ),
        ),
      ),
    );
  }
}
