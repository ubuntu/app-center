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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/collection/package_update_banner.dart';
import 'package:software/app/collection/package_updates_model.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/message_bar.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageUpdatesPage extends StatefulWidget {
  const PackageUpdatesPage({
    super.key,
  });

  @override
  State<PackageUpdatesPage> createState() => _PackageUpdatesPageState();
}

class _PackageUpdatesPageState extends State<PackageUpdatesPage> {
  @override
  void initState() {
    super.initState();
    final model = context.read<PackageUpdatesModel>();
    model.init(handleError: () => showSnackBar());
  }

  void showSnackBar() {
    if (!mounted) return;
    final model = context.read<PackageUpdatesModel>();
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
    final model = context.watch<PackageUpdatesModel>();

    if (model.updatesState == UpdatesState.readyToUpdate) {
      return const _UpdatesListView();
    }
    if (model.updatesState == UpdatesState.updating) {
      return const _UpdatingPage();
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _UpdatingPage extends StatefulWidget {
  const _UpdatingPage();

  @override
  State<_UpdatingPage> createState() => _UpdatingPageState();
}

class _UpdatingPageState extends State<_UpdatingPage> {
  //final terminalController = TerminalController();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageUpdatesModel>();

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
      YaruLinearProgressIndicator(
        value: model.percentage != null ? model.percentage! / 100 : 0,
      ),
      const SizedBox(
        height: 100,
      ),
      BorderContainer(
        color: Colors.transparent,
        child: YaruExpandable(
          header: Text(
            'Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          child: SizedBox(
            height: 300,
            width: 600,
            child: LogView(
              log: model.terminalOutput,
              style: TextStyle(
                inherit: false,
                fontFamily: 'Ubuntu Mono',
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ),
        ),
      ),
    ];

    return Center(
      child: SizedBox(
        width: 500,
        child: Column(
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

class PackageUpdatesHeader extends StatelessWidget {
  const PackageUpdatesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageUpdatesModel>();

    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(kPagePadding),
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          runAlignment: WrapAlignment.start,
          textDirection: TextDirection.rtl,
          spacing: 10,
          runSpacing: 10,
          children: [
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
                ),
          ],
        ),
      ),
    );
  }
}

class _UpdatesListView extends StatefulWidget {
  // ignore: unused_element
  const _UpdatesListView({super.key});

  @override
  State<_UpdatesListView> createState() => _UpdatesListViewState();
}

class _UpdatesListViewState extends State<_UpdatesListView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageUpdatesModel>();

    return BorderContainer(
      margin: const EdgeInsets.only(
        left: kYaruPagePadding,
        right: kYaruPagePadding,
        bottom: kYaruPagePadding,
      ),
      padding: EdgeInsets.zero,
      child: YaruExpandable(
        expandIconPadding: const EdgeInsets.only(right: 10),
        isExpanded: _isExpanded,
        onChange: (isExpanded) => setState(() => _isExpanded = isExpanded),
        header: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.only(
              top: kYaruPagePadding,
              left: kYaruPagePadding - 3,
              bottom: 20,
              right: kYaruPagePadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                YaruCheckbox(
                  value: model.allSelected
                      ? true
                      : model.nothingSelected
                          ? false
                          : null,
                  tristate: true,
                  onChanged: (v) =>
                      v != null ? model.selectAll() : model.deselectAll(),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    '${model.selectedUpdatesLength}/${model.updates.length} ${context.l10n.xSelected}',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              thickness: 0.0,
              height: 0,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: model.updates.length,
              itemBuilder: (context, index) {
                final update = model.getUpdate(index);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PackageUpdateBanner(
                      group: model.getGroup(update),
                      selected: model.isUpdateSelected(update),
                      updateId: update,
                      installedId: model.getInstalledId(update.name) ?? update,
                      onChanged:
                          model.updatesState == UpdatesState.checkingForUpdates
                              ? null
                              : (v) => model.selectUpdate(update, v!),
                    ),
                    if (index != model.updates.length - 1)
                      const Divider(
                        thickness: 0.0,
                        height: 0,
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
