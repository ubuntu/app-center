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
import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gtk_application/gtk_application.dart';
import 'package:provider/provider.dart';
import 'package:software/app/app_model.dart';
import 'package:software/app/app_splash_screen.dart';
import 'package:software/app/common/animated_warning_icon.dart';
import 'package:software/app/common/dangerous_delayed_button.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/app/explore/explore_page.dart';
import 'package:software/app/installed/installed_page.dart';
import 'package:software/app/settings/settings_page.dart';
import 'package:software/app/updates/package_updates_page.dart';
import 'package:software/app/updates/updates_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
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
          supportedLocales: supportedLocales,
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

class PageItem {
  const PageItem({
    required this.titleBuilder,
    required this.builder,
    required this.iconBuilder,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder builder;
  final Widget Function(BuildContext context, bool selected) iconBuilder;
}

class _App extends StatefulWidget {
  // ignore: unused_element
  const _App({super.key});

  @override
  State<_App> createState() => __AppState();
}

class __AppState extends State<_App> {
  int _installedPageIndex = 0;
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
            return _CloseWindowConfirmDialog(
              onConfirm: () {
                model.quit();
              },
            );
          },
        ).then((_) => closeConfirmDialogOpen = false);
      },
    ).then((_) => _initialized = true);
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
    final width = MediaQuery.of(context).size.width;

    final pageItems = [
      PageItem(
        titleBuilder: ExplorePage.createTitle,
        builder: (context) =>
            ExplorePage.create(context, model.appIsOnline, model.errorMessage),
        iconBuilder: (context, selected) => selected
            ? const Icon(YaruIcons.compass_filled)
            : const Icon(YaruIcons.compass),
      ),
      PageItem(
        titleBuilder: InstalledPage.createTitle,
        builder: (context) => InstalledPage.create(
          context,
          (index) => _installedPageIndex = index,
          _installedPageIndex,
        ),
        iconBuilder: (context, selected) {
          if (model.snapChanges.isNotEmpty) {
            return _InstalledPageIcon(count: model.snapChanges.length);
          }
          return selected
              ? const Icon(YaruIcons.ok_filled)
              : const Icon(YaruIcons.ok);
        },
      ),
      PageItem(
        titleBuilder: PackageUpdatesPage.createTitle,
        builder: (context) => const UpdatesPage(),
        iconBuilder: (context, selected) {
          return _UpdatesIcon(
            count: model.updateAmount,
            updatesState: model.updatesState ?? UpdatesState.noUpdates,
          );
        },
      ),
      if (path != null)
        PageItem(
          titleBuilder: (c) => Text(context.l10n.packageInstaller),
          builder: (c) => PackagePage.create(
            context: context,
            path: path,
          ),
          iconBuilder: (context, selected) =>
              const Icon(YaruIcons.insert_object),
        ),
      PageItem(
        titleBuilder: SettingsPage.createTitle,
        builder: SettingsPage.create,
        iconBuilder: (context, selected) => selected
            ? const Icon(YaruIcons.settings_filled)
            : const Icon(YaruIcons.settings),
      ),
    ];

    return _initialized
        ? YaruNavigationPage(
            key: ValueKey(path),
            length: pageItems.length,
            initialIndex: _initialIndex,
            itemBuilder: (context, index, selected) => YaruNavigationRailItem(
              icon: pageItems[index].iconBuilder(context, selected),
              label: pageItems[index].titleBuilder(context),
              // tooltip: pageItems[index].tooltipMessage,
              style: width > 800 && width < 1200
                  ? YaruNavigationRailStyle.labelled
                  : width > 1200
                      ? YaruNavigationRailStyle.labelledExtended
                      : YaruNavigationRailStyle.compact,
            ),
            pageBuilder: (context, index) => pageItems[index].builder(context),
          )
        : const StoreSplashScreen();
  }
}

class _InstalledPageIcon extends StatelessWidget {
  // ignore: unused_element
  const _InstalledPageIcon({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      badgeColor: Theme.of(context).primaryColor,
      badgeContent: Text(
        count.toString(),
        style: badgeTextStyle,
      ),
      child: const IndeterminateCircularProgressIcon(),
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
        child: const IndeterminateCircularProgressIcon(),
      );
    } else if (updatesState == UpdatesState.updating) {
      return const IndeterminateCircularProgressIcon();
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

class _CloseWindowConfirmDialog extends StatelessWidget {
  const _CloseWindowConfirmDialog({
    Key? key,
    this.onConfirm,
  }) : super(key: key);

  final Function()? onConfirm;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const YaruCloseButton(
        alignment: Alignment.centerRight,
      ),
      titlePadding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                const AnimatedWarningIcon(),
                Text(
                  context.l10n.attention,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    context.l10n.quitDanger,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DangerousDelayedButton(
                  duration: const Duration(seconds: 3),
                  onPressed: onConfirm,
                  child: Text(
                    context.l10n.quit,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    context.l10n.cancel,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
