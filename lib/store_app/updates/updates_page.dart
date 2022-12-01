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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/message_bar.dart';
import 'package:software/store_app/updates/no_updates_page.dart';
import 'package:software/store_app/updates/update_banner.dart';
import 'package:software/store_app/updates/updates_model.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_session/ubuntu_session.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:xterm/ui.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesModel(
        getService<PackageService>(),
        getService<UbuntuSession>(),
      ),
      child: const UpdatesPage(),
    );
  }

  static Widget createTitle(BuildContext context) => Text(context.l10n.updates);

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  @override
  void initState() {
    super.initState();
    final model = context.read<UpdatesModel>();
    model.init(handleError: () => showSnackBar());
  }

  void showSnackBar() {
    if (!mounted) return;
    final model = context.read<UpdatesModel>();
    if (model.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(minutes: 1),
          padding: EdgeInsets.zero,
          content: MessageBar(
            message: model.errorMessage,
            copyMessage: context.l10n.copyErrorMessage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();
    final hPadding = (0.00013 * pow(MediaQuery.of(context).size.width, 2)) - 20;

    return Column(
      children: [
        _UpdatesHeader(hPadding: hPadding),
        if (model.updatesState == UpdatesState.noUpdates ||
            model.updatesState == null)
          const NoUpdatesPage(),
        if (model.updatesState == UpdatesState.readyToUpdate)
          _UpdatesListView(hPadding: hPadding),
        if (model.updatesState == UpdatesState.updating)
          _UpdatingPage(hPadding: hPadding),
        if (model.updatesState == UpdatesState.checkingForUpdates)
          _CheckForUpdatesSplashScreen(
            percentage: model.percentage,
          )
      ],
    );
  }
}

class _CheckForUpdatesSplashScreen extends StatefulWidget {
  const _CheckForUpdatesSplashScreen({
    // ignore: unused_element
    super.key,
    this.percentage,
  });

  final int? percentage;

  @override
  State<_CheckForUpdatesSplashScreen> createState() =>
      _CheckForUpdatesSplashScreenState();
}

class _CheckForUpdatesSplashScreenState
    extends State<_CheckForUpdatesSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 145,
                  height: 185,
                  child: LiquidLinearProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).primaryColor,
                    ),
                    direction: Axis.vertical,
                    borderRadius: 20,
                  ),
                ),
                Icon(
                  YaruIcons.debian,
                  size: 120,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            Center(
              child: Text(
                context.l10n.justAMoment,
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(
              height: kYaruPagePadding / 4,
            ),
            Center(
              child: Text(
                context.l10n.checkingForUpdates,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(
              height: 120,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdatingPage extends StatefulWidget {
  const _UpdatingPage({
    Key? key,
    required this.hPadding,
  }) : super(key: key);

  final double hPadding;

  @override
  State<_UpdatingPage> createState() => _UpdatingPageState();
}

class _UpdatingPageState extends State<_UpdatingPage> {
  final terminalController = TerminalController();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();

    final children = [
      Text(
        model.info != null ? model.info!.name : '',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        model.processedId != null ? model.processedId!.name : '',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(
        height: 20,
      ),
      Padding(
        padding: EdgeInsets.only(
          left: widget.hPadding * 1.5,
          right: widget.hPadding * 1.5,
        ),
        child: YaruLinearProgressIndicator(
          value: model.percentage != null ? model.percentage! / 100 : 0,
        ),
      ),
      const SizedBox(
        height: 100,
      ),
      Padding(
        padding: EdgeInsets.only(left: widget.hPadding, right: widget.hPadding),
        child: BorderContainer(
          color: Colors.transparent,
          child: YaruExpandable(
            header: Text(
              'Details',
              style: Theme.of(context).textTheme.headline6,
            ),
            child: SizedBox(
              height: 300,
              width: 600,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: kYaruPagePadding,
                ),
                child: TerminalView(
                  model.terminal,
                  controller: terminalController,
                  theme: generateTerminalTheme(Theme.of(context)),
                ),
              ),
            ),
          ),
        ),
      ),
    ];

    return Expanded(
      child: Center(
        child: ListView(
          children: [
            for (final child in children)
              Center(
                child: child,
              )
          ],
        ),
      ),
    );
  }
}

class _UpdatesHeader extends StatelessWidget {
  const _UpdatesHeader({
    Key? key,
    required this.hPadding,
  }) : super(key: key);

  final double hPadding;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(top: 20, bottom: 20, right: hPadding),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          runAlignment: WrapAlignment.start,
          textDirection: TextDirection.rtl,
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: model.updatesState == UpdatesState.updating ||
                      model.updatesState == UpdatesState.checkingForUpdates
                  ? null
                  : () => model.refresh(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    YaruIcons.refresh,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(context.l10n.refreshButton)
                ],
              ),
            ),
            if (model.updates.isNotEmpty)
              ElevatedButton(
                onPressed: model.updatesState == UpdatesState.readyToUpdate &&
                        !model.nothingSelected
                    ? () => model.updateAll(
                          updatesComplete: context.l10n.updatesComplete,
                          updatesAvailable: context.l10n.updateAvailable,
                        )
                    : null,
                child: Text(context.l10n.updateButton),
              ),
            if (model.updatesState == UpdatesState.noUpdates)
              if (model.requireRestartApp)
                ElevatedButton(
                  onPressed: () => model.exitApp(),
                  child: Text(context.l10n.requireRestartApp),
                )
              else if (model.requireRestartSession)
                ElevatedButton(
                  onPressed: () => model.logout(),
                  child: Text(context.l10n.requireRestartSession),
                )
              else if (model.requireRestartSystem)
                ElevatedButton(
                  onPressed: () => model.reboot(),
                  child: Text(context.l10n.requireRestartSystem),
                )
          ],
        ),
      ),
    );
  }
}

class _UpdatesListView extends StatefulWidget {
  // ignore: unused_element
  const _UpdatesListView({super.key, required this.hPadding});

  final double hPadding;

  @override
  State<_UpdatesListView> createState() => _UpdatesListViewState();
}

class _UpdatesListViewState extends State<_UpdatesListView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();

    return Expanded(
      child: ListView(
        children: [
          const XdgIcon(
            name: 'aptdaemon-upgrade',
            theme: 'Yaru',
            size: 100,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              context.l10n.weHaveUpdates,
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          BorderContainer(
            childPadding: EdgeInsets.only(
              top: 20,
              bottom: 50,
              left: widget.hPadding,
              right: widget.hPadding,
            ),
            child: YaruExpandable(
              isExpanded: _isExpanded,
              onChange: (isExpanded) =>
                  setState(() => _isExpanded = isExpanded),
              header: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: _isExpanded
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          YaruCheckbox(
                            value: model.allSelected
                                ? true
                                : model.nothingSelected
                                    ? false
                                    : null,
                            tristate: true,
                            onChanged: (v) => v != null
                                ? model.selectAll()
                                : model.deselectAll(),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${model.selectedUpdatesLength}/${model.updates.length} ${context.l10n.xSelected}',
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      )
                    : Text(
                        '${model.selectedUpdatesLength}/${model.updates.length} ${context.l10n.xSelected}',
                        style: Theme.of(context).textTheme.headline6,
                      ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: kYaruPagePadding),
                child: Column(
                  children: List.generate(model.updates.length, (index) {
                    final update = model.getUpdate(index);
                    return SizedBox(
                      height: 70,
                      child: UpdateBanner(
                        group: model.getGroup(update),
                        selected: model.isUpdateSelected(update),
                        updateId: update,
                        installedId:
                            model.getInstalledId(update.name) ?? update,
                        onChanged: model.updatesState ==
                                UpdatesState.checkingForUpdates
                            ? null
                            : (v) => model.selectUpdate(update, v!),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TerminalTheme generateTerminalTheme(ThemeData themeData) {
  final light = themeData.brightness == Brightness.light;
  return TerminalTheme(
    cursor: light ? YaruColors.inkstone : YaruColors.porcelain,
    selection: themeData.primaryColor,
    foreground: themeData.colorScheme.onSurface,
    background: themeData.colorScheme.surface,
    black: YaruColors.jet,
    white: YaruColors.porcelain,
    red: YaruColors.error,
    green: light ? kGreenLight : kGreenDark,
    yellow: YaruColors.warning,
    blue: YaruColors.blue,
    magenta: YaruColors.magenta,
    cyan: Colors.cyan,
    brightBlack: YaruColors.inkstone,
    brightRed: YaruColors.red,
    brightGreen: kGreenLight,
    brightYellow: Colors.yellow,
    brightBlue: Colors.lightBlue,
    brightMagenta: const Color.fromARGB(255, 208, 79, 236),
    brightCyan: const Color.fromARGB(255, 44, 215, 238),
    brightWhite: Colors.white,
    searchHitBackground: themeData.colorScheme.background,
    searchHitBackgroundCurrent: themeData.colorScheme.surface,
    searchHitForeground: themeData.colorScheme.onSurface,
  );
}
