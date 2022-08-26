import 'package:badges/badges.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/explore/explore_page.dart';
import 'package:software/store_app/my_apps/my_apps_page.dart';
import 'package:software/store_app/settings/settings_page.dart';
import 'package:software/store_app/store_model.dart';
import 'package:software/store_app/updates/updates_page.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StoreApp extends StatefulWidget {
  const StoreApp({super.key});

  static Widget create() => ChangeNotifierProvider(
        create: (context) => StoreModel(
          getService<Connectivity>(),
          getService<AppChangeService>(),
          getService<PackageService>(),
        ),
        child: const StoreApp(),
      );

  @override
  State<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends State<StoreApp> {
  int _myAppsIndex = 0;

  @override
  void initState() {
    context.read<StoreModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<StoreModel>();
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          theme: yaru.variant?.theme ?? yaruLight,
          darkTheme: yaru.variant?.darkTheme ?? yaruDark,
          debugShowCheckedModeBanner: false,
          title: 'Ubuntu Software App',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => context.l10n.appTitle,
          routes: {
            Navigator.defaultRouteName: (context) {
              return Scaffold(
                body: YaruCompactLayout(
                  labelType: NavigationRailLabelType.all,
                  pageItems: [
                    YaruPageItem(
                      titleBuilder: ExplorePage.createTitle,
                      builder: (context) =>
                          ExplorePage.create(context, model.appIsOnline),
                      iconData: YaruIcons.compass,
                    ),
                    YaruPageItem(
                      titleBuilder: MyAppsPage.createTitle,
                      builder: (context) => MyAppsPage.create(
                        context,
                        (index) => _myAppsIndex = index,
                        _myAppsIndex,
                      ),
                      iconData: YaruIcons.ok,
                      itemWidget: model.snapChanges.isNotEmpty
                          ? _MyAppsIcon(count: model.snapChanges.length)
                          : null,
                    ),
                    YaruPageItem(
                      titleBuilder: UpdatesPage.createTitle,
                      builder: UpdatesPage.create,
                      iconData: YaruIcons.synchronizing,
                      itemWidget: model.updatesState == UpdatesState.noUpdates
                          ? null
                          : _UpdatesIcon(
                              count: model.updateAmount,
                              updatesState:
                                  model.updatesState ?? UpdatesState.noUpdates,
                            ),
                    ),
                    const YaruPageItem(
                      titleBuilder: SettingsPage.createTitle,
                      builder: SettingsPage.create,
                      iconData: YaruIcons.settings,
                    ),
                  ],
                ),
              );
            },
          },
        );
      },
    );
  }
}

class _MyAppsIcon extends StatelessWidget {
  // ignore: unused_element
  const _MyAppsIcon({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      badgeColor: Theme.of(context).primaryColor.withOpacity(0.2),
      badgeContent: Text(count.toString()),
      child: const SizedBox(
        height: 20,
        child: YaruCircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _UpdatesIcon extends StatelessWidget {
  const _UpdatesIcon({
    // ignore: unused_element
    super.key,
    required this.count,
    required this.updatesState,
  });

  final int count;
  final UpdatesState updatesState;

  @override
  Widget build(BuildContext context) {
    if (updatesState == UpdatesState.checkingForUpdates) {
      if (count > 0) {
        return Badge(
          badgeColor: Theme.of(context).primaryColor.withOpacity(0.2),
          badgeContent: Text(count.toString()),
          child: const SizedBox(
            height: 20,
            child: YaruCircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      } else if (count == 0) {
        return Badge(
          badgeColor: Theme.of(context).primaryColor.withOpacity(0.2),
          badgeContent: Text(count.toString()),
          child: const SizedBox(
            height: 20,
            child: Icon(YaruIcons.synchronizing),
          ),
        );
      }
    } else if (updatesState == UpdatesState.updating) {
      return const SizedBox(
        height: 20,
        child: YaruCircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }
    return const Icon(YaruIcons.synchronizing);
  }
}
