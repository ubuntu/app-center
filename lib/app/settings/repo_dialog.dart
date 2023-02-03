import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/common/message_bar.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/app/updates/package_updates_model.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_session/ubuntu_session.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RepoDialog extends StatefulWidget {
  const RepoDialog({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider<PackageUpdatesModel>(
      create: (context) => PackageUpdatesModel(
        getService<PackageService>(),
        getService<UbuntuSession>(),
      ),
      child: const RepoDialog(),
    );
  }

  @override
  State<RepoDialog> createState() => _RepoDialogState();
}

class _RepoDialogState extends State<RepoDialog> {
  late TextEditingController controller;

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

  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    context
        .read<PackageUpdatesModel>()
        .init(handleError: () => showSnackBar(), loadRepoList: true)
        .then((_) => _initialized = true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageUpdatesModel>();

    final ready = (model.updatesState != UpdatesState.updating &&
            model.updatesState != UpdatesState.checkingForUpdates) &&
        _initialized;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          YaruDialogTitleBar(
            leading: YaruBackButton(
              style: YaruBackButtonStyle.rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: ready
                ? Row(
                    children: [
                      IconButton(
                        onPressed: controller.text.isEmpty
                            ? null
                            : () => model.addRepo(),
                        icon: const Icon(YaruIcons.plus),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: 300,
                        height: 35,
                        child: TextField(
                          onChanged: (value) => model.manualRepoName = value,
                          controller: controller,
                          decoration: InputDecoration(
                            isDense: false,
                            hintText: context.l10n.enterRepoName,
                          ),
                        ),
                      )
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          if (!ready)
            const Expanded(
              child: Center(child: YaruCircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  for (final e in model.repos)
                    ListTile(
                      enabled: model.updatesState != UpdatesState.updating &&
                          model.updatesState != UpdatesState.checkingForUpdates,
                      trailing: YaruCheckbox(
                        value: e.enabled,
                        onChanged: (v) =>
                            model.toggleRepo(id: e.repoId, value: v!),
                      ),
                      title: ListTile(
                        title: Text(e.repoId),
                        subtitle: Text(e.description),
                      ),
                    )
                ],
              ),
            )
        ],
      ),
    );
  }
}
