import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/my_apps/package_dialog.dart';
import 'package:software/store_app/updates/updates_model.dart';
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
    final model = context.read<UpdatesModel>();
    model.getUpdates();
    model.loadRepoList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();
    if (model.errorString.isNotEmpty) {
      return Center(
        child: Row(
          children: [
            Text(model.errorString),
          ],
        ),
      );
    }

    if (model.updating) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Padding(
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
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 40,
                child: YaruRoundIconButton(
                  onTap: () => model.getUpdates(),
                  child: const Icon(YaruIcons.refresh),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              if (model.updates.isNotEmpty)
                OutlinedButton(
                  onPressed: model.updating
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
              const SizedBox(
                width: 10,
              ),
              if (model.updates.isNotEmpty)
                ElevatedButton(
                  onPressed: model.updating ? null : () => model.updateAll(),
                  child: Text(context.l10n.updateSelected),
                ),
            ],
          ),
        ),
        Expanded(
          child: model.updates.isEmpty
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.noUpdates,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: kGridDelegate,
                  itemCount: model.updates.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final update = model.updates.entries.elementAt(index).key;
                    return Stack(
                      children: [
                        YaruBanner(
                          name: update.name,
                          summary: update.version,
                          fallbackIconData: YaruIcons.package_deb,
                          icon: const Icon(
                            YaruIcons.package_deb,
                            size: 50,
                          ),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) =>
                                PackageDialog.create(context, update),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CheckboxTheme(
                              data: Theme.of(context).checkboxTheme.copyWith(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(9),
                                        bottomLeft: Radius.circular(2),
                                        topLeft: Radius.circular(2),
                                        bottomRight: Radius.circular(2),
                                      ),
                                    ),
                                  ),
                              child: Checkbox(
                                value: model.updates[update],
                                onChanged: (v) =>
                                    model.selectUpdate(update, v!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
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
