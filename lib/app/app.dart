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
import 'package:provider/provider.dart';
import 'package:software/app/app_model.dart';
import 'package:software/app/app_splash_screen.dart';
import 'package:software/app/common/close_confirmation_dialog.dart';
import 'package:software/app/common/page_item.dart';
import 'package:software/app/explore/explore_page.dart';
import 'package:software/app/installed/installed_page.dart';
import 'package:software/app/package_installer/package_installer_page.dart';
import 'package:software/app/settings/settings_page.dart';
import 'package:software/app/updates/updates_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class App extends StatelessWidget {
  const App({super.key});

  static Widget create() => ChangeNotifierProvider(
        create: (context) => AppModel(
          getService<Connectivity>(),
          getService<SnapService>(),
          getService<AppstreamService>(),
          getService<PackageService>(),
        ),
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
  int _updatesPageIndex = 0;
  bool _initialized = false;
  int _initialIndex = 0;
  String? path;

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
      path = args.where((arg) => arg.endsWith('.deb')).firstOrNull;
      if (path != null) {
        _initialIndex = 3;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();
    model.setupNotifications(updatesAvailable: context.l10n.updateAvailable);

    final pageItems = [
      PageItem(
        titleBuilder: ExplorePage.createTitle,
        builder: (context) =>
            ExplorePage.create(context, model.appIsOnline, model.errorMessage),
        iconBuilder: ExplorePage.createIcon,
      ),
      PageItem(
        titleBuilder: InstalledPage.createTitle,
        builder: (context) => InstalledPage.create(context),
        iconBuilder: (context, selected) => InstalledPage.createIcon(
          context: context,
          selected: selected,
          badgeCount: model.snapChanges.length,
          processing: model.snapChanges.isNotEmpty,
        ),
      ),
      PageItem(
        titleBuilder: UpdatesPage.createTitle,
        builder: (context) => UpdatesPage(
          onTabTapped: (index) => setState(() => _updatesPageIndex = index),
          tabIndex: _updatesPageIndex,
        ),
        iconBuilder: (context, selected) => UpdatesPage.createIcon(
          context: context,
          selected: selected,
          badgeCount: model.updateAmount,
          processing: model.updatesProcessing,
        ),
      ),
      if (path != null)
        PageItem(
          titleBuilder: (context) => Text(context.l10n.packageInstaller),
          builder: (context) => PackageInstallerPage.create(
            context: context,
            path: path,
          ),
          iconBuilder: (context, selected) =>
              PackageInstallerPage.createIcon(context, selected),
        ),
      PageItem(
        titleBuilder: SettingsPage.createTitle,
        builder: SettingsPage.create,
        iconBuilder: (context, selected) =>
            SettingsPage.createIcon(context, selected),
      ),
    ];

    return _initialized
        ? YaruMasterDetailPage(
            layoutDelegate: const YaruMasterFixedPaneDelegate(paneWidth: 220),
            appBar: const YaruWindowTitleBar(
              isClosable: false,
              isMaximizable: false,
              isMinimizable: false,
              isRestorable: false,
            ),
            key: ValueKey(path),
            length: pageItems.length,
            initialIndex: _initialIndex,
            tileBuilder: (context, index, selected) => YaruMasterTile(
              leading: pageItems[index].iconBuilder(context, selected),
              title: pageItems[index].titleBuilder(context),
              // tooltip: pageItems[index].tooltipMessage,
            ),
            pageBuilder: (context, index) => pageItems[index].builder(context),
          )
        : const StoreSplashScreen();
  }
}
