import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/updates/update_banner.dart';
import 'package:software/store_app/updates/updates_model.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesModel(
        getService<PackageKitClient>(),
      ),
      child: const UpdatesPage(),
    );
  }

  static Widget createTitle(BuildContext context) {
    return Text(context.l10n.updates);
  }

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  @override
  void initState() {
    context.read<UpdatesModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();
    if (model.errorString.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(child: Text(model.errorString)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const _UpdatesHeader(),
        if (model.updatesState == UpdatesState.noUpdates)
          const _NoUpdatesPage(),
        if (model.updatesState == UpdatesState.readyToUpdate)
          const _UpdatesListView(),
        if (model.updatesState == UpdatesState.updating) const _UpdatingPage(),
        if (model.updatesState == UpdatesState.checkingForUpdates)
          _CheckForUpdatesSplashScreen(
            percentage: model.percentage,
          )
      ],
    );
  }
}

class _CheckForUpdatesSplashScreen extends StatelessWidget {
  const _CheckForUpdatesSplashScreen({
    // ignore: unused_element
    super.key,
    this.percentage,
  });

  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 145,
                height: 185,
                child: LiquidLinearProgressIndicator(
                  value: percentage == null ? 0 : percentage! / 100,
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdatingPage extends StatelessWidget {
  const _UpdatingPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.processedId != null ? model.processedId!.name : '',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              model.info != null ? model.info!.name : '',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 400,
              child: YaruLinearProgressIndicator(
                value: model.percentage != null ? model.percentage! / 100 : 0,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(model.status != null ? model.status!.name : ''),
            const SizedBox(
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdatesHeader extends StatelessWidget {
  const _UpdatesHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          YaruRoundIconButton(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ChangeNotifierProvider.value(
                    value: model,
                    child: const _RepoDialog(),
                  );
                },
              );
            },
            child: const Icon(YaruIcons.settings),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SizedBox(
              width: 40,
              child: model.updatesState == UpdatesState.noUpdates ||
                      model.updatesState == UpdatesState.readyToUpdate
                  ? YaruRoundIconButton(
                      onTap: () => model.refresh(),
                      child: const Icon(YaruIcons.refresh),
                    )
                  : const SizedBox(
                      height: 25,
                      child: YaruCircularProgressIndicator(
                        strokeWidth: 4,
                      ),
                    ),
            ),
          ),
          if (model.updates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: OutlinedButton(
                onPressed: model.updatesState == UpdatesState.updating
                    ? null
                    : model.allSelected
                        ? () => model.deselectAll()
                        : () => model.selectAll(),
                child: Text(
                  model.allSelected
                      ? context.l10n.deselectAll
                      : context.l10n.selectAll,
                ),
              ),
            ),
          if (model.updates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ElevatedButton(
                onPressed: model.updatesState == UpdatesState.readyToUpdate
                    ? () => model.updateAll()
                    : null,
                child: Text(context.l10n.updateSelected),
              ),
            ),
          if (model.requireRestart &&
              model.updatesState == UpdatesState.noUpdates)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ElevatedButton(
                onPressed: () => model.reboot(),
                child: Text(context.l10n.requireRestart),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpdatesListView extends StatelessWidget {
  // ignore: unused_element
  const _UpdatesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final hPadding = getHPadding(MediaQuery.of(context).size.width);
    final model = context.watch<UpdatesModel>();

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 50,
          bottom: 50,
          left: hPadding,
          right: hPadding,
        ),
        itemCount: model.updates.length,
        itemExtent: 100,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final update = model.getUpdate(index);

          return UpdateBanner(
            group: model.idsToGroups[update] ?? PackageKitGroup.unknown,
            selected: model.updates[update],
            updateId: update,
            installedId: model.installedPackages[update.name] ?? update,
            onChanged: model.updatesState == UpdatesState.checkingForUpdates
                ? null
                : (v) => model.selectUpdate(update, v!),
          );
        },
      ),
    );
  }

  double getHPadding(double width) {
    var padding = 550.0;
    for (int i in [1800, 1700, 1600, 1500, 1400, 1300, 1200, 1100, 1000, 900]) {
      if (width > i) {
        return padding;
      }
      padding -= 50;
    }
    return padding;
  }
}

class _NoUpdatesPage extends StatelessWidget {
  const _NoUpdatesPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                YaruAnimatedOkIcon(
                  size: 90,
                  filled: true,
                  color: Theme.of(context).brightness == Brightness.light
                      ? positiveGreenLightTheme
                      : positiveGreenDarkTheme,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  context.l10n.noUpdates,
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RepoDialog extends StatefulWidget {
  // ignore: unused_element
  const _RepoDialog({super.key});

  @override
  State<_RepoDialog> createState() => _RepoDialogState();
}

class _RepoDialogState extends State<_RepoDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();

    return SimpleDialog(
      title: YaruDialogTitle(
        closeIconData: YaruIcons.window_close,
        titleWidget: Row(
          children: [
            YaruRoundIconButton(
              onTap: controller.text.isEmpty ? null : () => model.addRepo(),
              child: const Icon(YaruIcons.plus),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                onChanged: (value) => model.manualRepoName = value,
                controller: controller,
                decoration: InputDecoration(
                  hintText: context.l10n.enterRepoName,
                  border: const UnderlineInputBorder(),
                ),
              ),
            )
          ],
        ),
      ),
      titlePadding: EdgeInsets.zero,
      children: model.repos
          .map(
            (e) => CheckboxListTile(
              value: e.enabled,
              onChanged: (v) => model.toggleRepo(id: e.repoId, value: v!),
              title: ListTile(
                title: Text(e.repoId),
                subtitle: Text(e.description),
              ),
            ),
          )
          .toList(),
    );
  }
}
