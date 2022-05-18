import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/explore/explore_page.dart';
import 'package:software/pages/my_apps/my_apps_page.dart';
import 'package:software/pages/settings/settings_page.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

void main() async {
  runApp(MultiProvider(
    providers: [
      Provider<SnapdClient>(
        create: (_) => SnapdClient(),
        dispose: (_, client) => client.close(),
      ),
    ],
    child: App(),
  ));
}

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: TouchMouseStylusScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Ubuntu Software App',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (context) => context.l10n.appTitle,
      routes: {
        Navigator.defaultRouteName: (context) => YaruTheme(
              child: Scaffold(
                body: YaruCompactLayout(
                  pageItems: pageItems,
                ),
              ),
            ),
      },
    );
  }
}

final pageItems = [
  YaruPageItem(
    titleBuilder: ExplorePage.createTitle,
    builder: ExplorePage.create,
    iconData: YaruIcons.compass,
  ),
  YaruPageItem(
    titleBuilder: MyAppsPage.createTitle,
    builder: MyAppsPage.create,
    iconData: YaruIcons.app_grid,
  ),
  YaruPageItem(
    titleBuilder: (context) => Text('Updates'),
    builder: (_) => Center(child: Text('Updates')),
    iconData: YaruIcons.synchronizing,
  ),
  YaruPageItem(
    titleBuilder: SettingsPage.createTitle,
    builder: SettingsPage.create,
    iconData: YaruIcons.settings,
  )
];

class TouchMouseStylusScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus
      };
}
