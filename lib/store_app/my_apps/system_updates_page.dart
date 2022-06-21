import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/my_apps/package_dialog.dart';
import 'package:software/store_app/my_apps/system_updates_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SystemUpdatesPage extends StatefulWidget {
  const SystemUpdatesPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SystemUpdatesModel(
        getService<PackageKitClient>(),
      ),
      child: const SystemUpdatesPage(),
    );
  }

  @override
  State<SystemUpdatesPage> createState() => _SystemUpdatesPageState();
}

class _SystemUpdatesPageState extends State<SystemUpdatesPage> {
  @override
  void initState() {
    final model = context.read<SystemUpdatesModel>();
    model.getUpdates();
    model.loadRepoList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SystemUpdatesModel>();
    if (model.errorString.isNotEmpty) {
      return Center(
        child: Row(
          children: [
            Text(model.errorString),
          ],
        ),
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
              if (model.updates.isNotEmpty)
                ElevatedButton(
                  onPressed: model.updating ? null : () => model.updateAll(),
                  child: Text(context.l10n.updateAll),
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
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: kGridDelegate,
                  itemCount: model.updates.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return AppBanner(
                      name: model.updates[index].name,
                      icon: const Icon(
                        YaruIcons.package_deb,
                        size: 50,
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) =>
                            PackageDialog.create(context, model.updates[index]),
                      ),
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
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SystemUpdatesModel>();

    return SimpleDialog(
      title: YaruDialogTitle(
        closeIconData: YaruIcons.window_close,
        titleWidget: Row(
          children: [
            YaruRoundIconButton(
              onTap: controller.text.isNotEmpty
                  ? () => model.addRepo(controller.text)
                  : null,
              child: const Icon(YaruIcons.plus),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 300,
              child: TextField(
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
                leading: YaruRoundIconButton(
                  child: const Icon(YaruIcons.trash),
                  onTap: () => model.removeRepo(e.repoId),
                ),
                title: Text(e.repoId),
                subtitle: Text(e.description),
                isThreeLine: true,
              ),
            ),
          )
          .toList(),
    );
  }
}
