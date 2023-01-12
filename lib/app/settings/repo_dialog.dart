import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/app/updates/package_updates_model.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RepoDialog extends StatefulWidget {
  // ignore: unused_element
  const RepoDialog({super.key});

  @override
  State<RepoDialog> createState() => _RepoDialogState();
}

class _RepoDialogState extends State<RepoDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageUpdatesModel>();

    return SimpleDialog(
      title: YaruDialogTitleBar(
        title: model.updatesState != UpdatesState.updating &&
                model.updatesState != UpdatesState.checkingForUpdates
            ? Row(
                children: [
                  IconButton(
                    onPressed:
                        controller.text.isEmpty ? null : () => model.addRepo(),
                    icon: const Icon(YaruIcons.plus),
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
                        isDense: false,
                        hintText: context.l10n.enterRepoName,
                        border: const UnderlineInputBorder(),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                  )
                ],
              )
            : const SizedBox(),
      ),
      titlePadding: EdgeInsets.zero,
      children: model.repos
          .map(
            (e) => ListTile(
              enabled: model.updatesState != UpdatesState.updating &&
                  model.updatesState != UpdatesState.checkingForUpdates,
              trailing: YaruCheckbox(
                value: e.enabled,
                onChanged: (v) => model.toggleRepo(id: e.repoId, value: v!),
              ),
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
