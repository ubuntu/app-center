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

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gtk_application/gtk_application.dart';
import 'package:launcher_entry/launcher_entry.dart';
import 'package:provider/provider.dart';
import 'package:software/app/app_model.dart';
import 'package:software/app/app_splash_screen.dart';
import 'package:software/app/common/close_confirmation_dialog.dart';
import 'package:software/app/common/connectivity_notifier.dart';
import 'package:software/app/common/page_item.dart';
import 'package:software/app/common/rating_model.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:software/app/explore/explore_page.dart';
import 'package:software/app/installed/installed_page.dart';
import 'package:software/app/package_installer/package_installer_page.dart';
import 'package:software/app/settings/settings_page.dart';
import 'package:software/app/updates/updates_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/odrs_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class App extends StatelessWidget {
  const App({super.key});

  static Widget create() => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AppModel(
              getService<SnapService>(),
              getService<AppstreamService>(),
              getService<PackageService>(),
              getService<LauncherEntryService>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => ConnectivityNotifier(getService<Connectivity>()),
          ),
          ChangeNotifierProvider(
            create: (_) => RatingModel(getService<OdrsService>()),
          ),
          ChangeNotifierProvider(
            create: (_) => ExploreModel(
              getService<AppstreamService>(),
              getService<SnapService>(),
              getService<PackageService>(),
            )..init(),
          )
        ],
        child: const App(),
      );

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return YaruTheme(
          builder: (context, yaru, child) {
            return MaterialApp(
              theme: yaru.theme,
              darkTheme: yaru.darkTheme,
              themeMode: currentMode,
              debugShowCheckedModeBanner: false,
              title: 'Ubuntu Software App',
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: supportedLocales,
              onGenerateTitle: (context) => context.l10n.appTitle,
              routes: {
                Navigator.defaultRouteName: (context) {
                  return const _App();
                },
              },
            );
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
  bool _initialized = false;
  int _initialIndex = 0;
  String? debPath;
  String? snapName;

  @override
  void initState() {
    super.initState();

    final gtkNotifier = getService<GtkApplicationNotifier>();
    _commandLineListener(gtkNotifier.commandLine!);
    gtkNotifier.addCommandLineListener(_commandLineListener);

    final model = context.read<AppModel>();
    var closeConfirmDialogOpen = false;

    model.init(
      onAskForQuit: () {
        if (closeConfirmDialogOpen) {
          return;
        }

        closeConfirmDialogOpen = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) {
            return CloseWindowConfirmDialog(
              onConfirm: () {
                model.quit();
              },
            );
          },
        ).then((_) => closeConfirmDialogOpen = false);
      },
    ).then((_) {
      setState(() {
        _initialized = true;
      });
    });
  }

  void _commandLineListener(List<String> args) {
    setState(() {
      debPath = args.where((arg) => arg.endsWith('.deb')).firstOrNull;
      snapName = args
          .where((arg) => arg.startsWith('snap://'))
          .firstOrNull
          ?.substring(7);
      if (debPath != null || snapName != null) {
        _initialIndex = 3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    context
        .read<AppModel>()
        .setupNotifications(updatesAvailable: context.l10n.updateAvailable);
    final badgeCount = context.select((AppModel m) => m.snapChanges.length);
    final processing = context.select((AppModel m) => m.snapChanges.isNotEmpty);
    final updateAmount = context.select((AppModel m) => m.updateAmount);
    final updatesProcessing =
        context.select((AppModel m) => m.updatesProcessing);
    final setSelectedIndex = context.select((AppModel m) => m.setSelectedIndex);

    final pageItems = [
      PageItem(
        titleBuilder: ExplorePage.createTitle,
        builder: (context) => const ExplorePage(),
        iconBuilder: ExplorePage.createIcon,
      ),
      PageItem(
        titleBuilder: InstalledPage.createTitle,
        builder: (context) => InstalledPage.create(context),
        iconBuilder: (context, selected) => InstalledPage.createIcon(
          context: context,
          selected: selected,
          badgeCount: badgeCount,
          processing: processing,
        ),
      ),
      PageItem(
        titleBuilder: UpdatesPage.createTitle,
        builder: (context) => UpdatesPage.create(
          context: context,
          windowWidth: width,
        ),
        iconBuilder: (context, selected) => UpdatesPage.createIcon(
          context: context,
          selected: selected,
          badgeCount: updateAmount,
          processing: updatesProcessing,
        ),
      ),
      if (debPath != null || snapName != null)
        PageItem(
          titleBuilder: (context) => Text(context.l10n.packageInstaller),
          builder: (context) => PackageInstallerPage.create(
            context: context,
            debPath: debPath,
            snapName: snapName,
          ),
          iconBuilder: (context, selected) =>
              PackageInstallerPage.createIcon(context, selected),
        ),
    ];

    var normalWindowSize = width > 800 && width < 1200;
    var wideWindowSize = width > 1200;
    final itemStyle = normalWindowSize
        ? YaruNavigationRailStyle.labelled
        : wideWindowSize
            ? YaruNavigationRailStyle.labelledExtended
            : YaruNavigationRailStyle.compact;

    return _initialized
        ? YaruNavigationPage(
            trailing: YaruNavigationRailItem(
              icon: SettingsPage.createIcon(context, false),
              label: SettingsPage.createTitle(context),
              style: itemStyle,
              onTap: () => showDialog(
                context: context,
                builder: (context) => SettingsPage.create(context),
              ),
            ),
            leading: AnimatedContainer(
              width: normalWindowSize
                  ? 100
                  : wideWindowSize
                      ? 250
                      : 60,
              duration: const Duration(milliseconds: 200),
              child: YaruWindowTitleBar(
                title: Text(wideWindowSize ? 'Ubuntu Software' : ''),
                style: YaruTitleBarStyle.undecorated,
              ),
            ),
            key: ValueKey((debPath ?? '') + (snapName ?? '')),
            length: pageItems.length,
            onSelected: (value) => setSelectedIndex(value),
            initialIndex: _initialIndex,
            itemBuilder: (context, index, selected) => YaruNavigationRailItem(
              icon: pageItems[index].iconBuilder(context, selected),
              label: pageItems[index].titleBuilder(context), style: itemStyle,
              // tooltip: pageItems[index].tooltipMessage,
            ),
            pageBuilder: (context, index) => pageItems[index].builder(context),
          )
        : const StoreSplashScreen();
  }
}
