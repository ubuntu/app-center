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
import 'package:software/store_app/settings/settings_model.dart';
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
    context.read<SettingsModel>().init();
    super.initState();
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
            return YaruPage(
              children: [
                YaruRow(
                  trailingWidget: Text(
                    '${model.appName} ${model.version} ${model.buildNumber}',
                  ),
                  actionWidget: TextButton(
                    onPressed: () {
                      showAboutDialog(
                        applicationVersion: model.version,
                        applicationIcon: Image.asset(
                          'assets/software.png',
                          width: 60,
                          filterQuality: FilterQuality.medium,
                        ),
                        children: [
                          SizedBox(
                            height: 300,
                            width: 300,
                            child: FutureBuilder<String>(
                              future: loadAsset(context),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Markdown(
                                    shrinkWrap: true,
                                    data: 'is made by:\n ${snapshot.data!}',
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
                  width: 500,
                )
              ],
            );
          },
        );
      },
    );
  }
}
