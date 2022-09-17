/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

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

class StoreApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          theme: yaru.theme,
          darkTheme: yaru.darkTheme,
          debugShowCheckedModeBanner: false,
          title: 'Ubuntu Software App',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => context.l10n.appTitle,
          routes: {
            Navigator.defaultRouteName: (context) {
              return const Scaffold(
                body: _App(),
              );
            },
          },
        );
      },
    );
  }
}

class _App extends StatefulWidget {
  // ignore: unused_element
  const _App({super.key});

  @override
  State<_App> createState() => __AppState();
}

class __AppState extends State<_App> {
  int _myAppsIndex = 0;

  @override
  void initState() {
    context.read<StoreModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<StoreModel>();
    final width = MediaQuery.of(context).size.width;

    return YaruCompactLayout(
      extendNavigationRail: width > 1200,
      labelType: width < 800 || width > 1200
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      pageItems: [
        YaruPageItem(
          titleBuilder: ExplorePage.createTitle,
          builder: (context) => ExplorePage.create(context, model.appIsOnline),
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
          itemWidget: _UpdatesIcon(
            count: model.updateAmount,
            updatesState: model.updatesState ?? UpdatesState.checkingForUpdates,
          ),
        ),
        const YaruPageItem(
          titleBuilder: SettingsPage.createTitle,
          builder: SettingsPage.create,
          iconData: YaruIcons.settings,
        ),
      ],
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
      badgeColor: Theme.of(context).primaryColor,
      badgeContent: Text(
        count.toString(),
        style: badgeTextStyle,
      ),
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
      return Badge(
        position: BadgePosition.topEnd(),
        badgeColor:
            count > 0 ? Theme.of(context).primaryColor : Colors.transparent,
        badgeContent: count > 0
            ? Text(
                count.toString(),
                style: badgeTextStyle,
              )
            : null,
        child: const SizedBox(
          height: 20,
          child: YaruCircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    } else if (updatesState == UpdatesState.updating) {
      return const SizedBox(
        height: 20,
        child: YaruCircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    } else if (updatesState == UpdatesState.readyToUpdate) {
      return Badge(
        badgeColor: Theme.of(context).primaryColor,
        badgeContent: Text(
          count.toString(),
          style: badgeTextStyle,
        ),
        child: const Icon(YaruIcons.synchronizing),
      );
    }
    return const Icon(YaruIcons.synchronizing);
  }
}

const badgeTextStyle = TextStyle(color: Colors.white, fontSize: 10);
