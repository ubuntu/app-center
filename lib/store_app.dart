import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/explore/explore_page.dart';
import 'package:software/pages/settings/settings_page.dart';
import 'package:software/pages/updates/updates_page.dart';
import 'package:software/store_model.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StoreApp extends StatefulWidget {
  const StoreApp({super.key});

  @override
  State<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends State<StoreApp> {
  @override
  void initState() {
    super.initState();
    final model = context.read<StoreModel>();
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<StoreModel>();

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
                  pageItems: [
                    if (model.appIsOnline)
                      const YaruPageItem(
                        titleBuilder: ExplorePage.createTitle,
                        builder: ExplorePage.create,
                        iconData: YaruIcons.compass,
                      ),
                    const YaruPageItem(
                      titleBuilder: SnapUpdatesPage.createTitle,
                      builder: SnapUpdatesPage.create,
                      iconData: YaruIcons.ok,
                    ),
                    if (model.appIsOnline)
                      const YaruPageItem(
                        titleBuilder: UpdatesPage.createTitle,
                        builder: UpdatesPage.create,
                        iconData: YaruIcons.synchronizing,
                      ),
                    const YaruPageItem(
                      titleBuilder: SettingsPage.createTitle,
                      builder: SettingsPage.create,
                      iconData: YaruIcons.settings,
                    )
                  ],
                ),
              ),
            ),
      },
    );
  }
}

class TouchMouseStylusScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus
      };
}
