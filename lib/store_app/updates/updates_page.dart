import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/updates/update_banner.dart';
import 'package:software/store_app/updates/updates_model.dart';
import 'package:software/updates_state.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdatesModel(),
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
    if (model.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(child: Text(model.errorMessage)),
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Stack(
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
              height: 250,
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
      padding: const EdgeInsets.only(right: 20, top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: model.updatesState != UpdatesState.readyToUpdate
                ? null
                : () => showDialog(
                      context: context,
                      builder: (context) {
                        return ChangeNotifierProvider.value(
                          value: model,
                          child: const _RepoDialog(),
                        );
                      },
                    ),
            child: Row(
              children: [
                const Icon(
                  YaruIcons.external_link,
                  size: 18,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(context.l10n.sources)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: OutlinedButton(
              onPressed: model.updatesState == UpdatesState.updating ||
                      model.updatesState == UpdatesState.checkingForUpdates
                  ? null
                  : () => model.refresh(),
              child: Row(
                children: [
                  model.updatesState == UpdatesState.noUpdates ||
                          model.updatesState == UpdatesState.readyToUpdate ||
                          model.updatesState == null
                      ? const Icon(
                          YaruIcons.refresh,
                          size: 18,
                        )
                      : const SizedBox(
                          height: 16,
                          width: 16,
                          child: YaruCircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(context.l10n.refresh)
                ],
              ),
            ),
          ),
          if (model.updates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: OutlinedButton(
                onPressed: model.updatesState != UpdatesState.readyToUpdate
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
          top: 20,
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
            group: model.getGroup(update),
            selected: model.isUpdateSelected(update),
            updateId: update,
            installedId: model.getInstalledId(update.name) ?? update,
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
