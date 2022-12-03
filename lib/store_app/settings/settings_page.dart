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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/message_bar.dart';
import 'package:software/store_app/settings/repo_dialog.dart';
import 'package:software/store_app/settings/settings_model.dart';
import 'package:software/store_app/updates/package_updates_model.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_session/ubuntu_session.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsModel(),
      child: const SettingsPage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.settingsPageTitle);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsModel>().init();
  }

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/contributors.md');
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsModel>();
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return Center(
              child: BorderContainer(
                width: 700,
                childPadding: const EdgeInsets.all(kYaruPagePadding),
                child: Column(
                  children: [
                    YaruTile(
                      title: Text(
                        '${model.appName} ${model.version} ${model.buildNumber}',
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          showAboutDialog(
                            applicationVersion: model.version,
                            applicationIcon: Image.asset(
                              'assets/software.png',
                              width: 60,
                              filterQuality: FilterQuality.medium,
                            ),
                            children: [
                              Center(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () async =>
                                      await launchUrl(Uri.parse(repoUrl)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        context.l10n.findOurRepository,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        YaruIcons.external_link,
                                        color: Theme.of(context).primaryColor,
                                        size: 18,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 400,
                                height: 600,
                                child: FutureBuilder<String>(
                                  future: loadAsset(context),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return MarkdownBody(
                                        data:
                                            '${context.l10n.madeBy}:\n ${snapshot.data!}',
                                        onTapLink: (text, href, title) =>
                                            href != null
                                                ? launchUrl(Uri.parse(href))
                                                : null,
                                      );
                                    } else {
                                      return const SizedBox();
                                    }
                                  },
                                ),
                              )
                            ],
                            context: context,
                            useRootNavigator: false,
                          );
                        },
                        child: Text(context.l10n.about),
                      ),
                      enabled: true,
                    ),
                    RepoTile.create(context)
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class RepoTile extends StatefulWidget {
  const RepoTile({super.key});

  @override
  State<RepoTile> createState() => _RepoTileState();

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider<UpdatesModel>(
      create: (context) => UpdatesModel(
        getService<PackageService>(),
        getService<UbuntuSession>(),
      ),
      child: const RepoTile(),
    );
  }
}

class _RepoTileState extends State<RepoTile> {
  @override
  void initState() {
    super.initState();
    context.read<UpdatesModel>().init(handleError: () => showSnackBar());
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
    return YaruTile(
      title: Text(context.l10n.sources),
      trailing: YaruOptionButton(
        onPressed: model.updatesState == UpdatesState.updating
            ? null
            : () => showDialog(
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider.value(
                      value: model,
                      child: const RepoDialog(),
                    );
                  },
                ),
        child: const Icon(
          YaruIcons.external_link,
          size: 18,
        ),
      ),
    );
  }
}
