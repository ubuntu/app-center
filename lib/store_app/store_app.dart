import 'package:badges/badges.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/explore/explore_page.dart';
import 'package:software/store_app/my_apps/my_apps_page.dart';
import 'package:software/store_app/settings/settings_page.dart';
import 'package:software/store_app/store_model.dart';
import 'package:software/store_app/updates/updates_page.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StoreApp extends StatefulWidget {
  const StoreApp({super.key});

  static Widget create() => ChangeNotifierProvider(
        create: (context) => StoreModel(),
        child: const StoreApp(),
      );

  @override
  State<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends State<StoreApp> {
  @override
  void initState() {
    context.read<StoreModel>().init();
    super.initState();
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
                    const YaruPageItem(
                      titleBuilder: ExplorePage.createTitle,
                      builder: ExplorePage.create,
                      iconData: YaruIcons.compass,
                    ),
                    YaruPageItem(
                      titleBuilder: MyAppsPage.createTitle,
                      builder: MyAppsPage.create,
                      iconData: YaruIcons.ok,
                      itemWidget: model.snapChanges.isNotEmpty
                          ? Badge(
                              badgeColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                              badgeContent:
                                  Text(model.snapChanges.length.toString()),
                              child: const SizedBox(
                                height: 20,
                                child: YaruCircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
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
