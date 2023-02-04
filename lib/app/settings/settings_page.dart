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
import 'package:software/app/app.dart';
import 'package:software/app/common/link.dart';
import 'package:software/app/settings/repo_dialog.dart';
import 'package:software/app/settings/settings_model.dart';
import 'package:software/app/settings/theme_tile.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/theme_mode_x.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsModel(getService<PackageService>()),
      child: const SettingsPage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.settingsPageTitle);

  static Widget createIcon(BuildContext context, bool selected) =>
      selected ? const Icon(YaruIcons.gear_filled) : const Icon(YaruIcons.gear);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator(
      onPopPage: (route, result) => route.didPop(result),
      key: Utils.settingsNav,
      initialRoute: '/settings',
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/settings':
            page = const _SettingsPage();
            break;
          case '/repoDialog':
            page = RepoDialog.create(context);
            break;
          case '/about':
            page = const _AboutDialog();
            break;
          case '/licenses':
            page = const _LicensePage();
            break;
          default:
            page = const _SettingsPage();
            break;
        }

        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(height: 800, width: 600, child: nav),
    );
  }

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/contributors.md');
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YaruDialogTitleBar(
          onClose: (p0) => Navigator.of(rootNavigator: true, context).pop(),
          title: SettingsPage.createTitle(context),
        ),
        Expanded(
          child: ListView(
            children: [
              const ThemeSection(),
              YaruSection(
                headline: Text(context.l10n.sources),
                margin: const EdgeInsets.all(kYaruPagePadding),
                child: Column(
                  children: const [
                    _RepoTile(),
                  ],
                ),
              ),
              YaruSection(
                headline: Text(context.l10n.about),
                margin:
                    const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
                child: Column(
                  children: const [_AboutTile(), _LicenseTile()],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ThemeSection extends StatefulWidget {
  const ThemeSection({super.key});

  @override
  State<ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<ThemeSection> {
  void onChanged(index) {
    setState(() {
      switch (index) {
        case 0:
          {
            App.themeNotifier.value = ThemeMode.system;
          }
          break;

        case 1:
          {
            App.themeNotifier.value = ThemeMode.light;
          }
          break;

        case 2:
          {
            App.themeNotifier.value = ThemeMode.dark;
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themes = [context.l10n.system, context.l10n.light, context.l10n.dark];
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kYaruPagePadding,
        top: kYaruPagePadding,
        right: kYaruPagePadding,
      ),
      headline: Text(context.l10n.theme),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: kYaruPagePadding),
          child: Wrap(
            spacing: kYaruPagePadding,
            children: [
              for (var i = 0; i < themes.length; ++i)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    YaruSelectableContainer(
                      padding: const EdgeInsets.all(1),
                      borderRadius: BorderRadius.circular(12),
                      selected: App.themeNotifier.value == ThemeMode.values[i],
                      onTap: () => onChanged(i),
                      child: ThemeTile(ThemeMode.values[i]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(ThemeMode.values[i].localize(context.l10n)),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepoTile extends StatefulWidget {
  const _RepoTile();

  @override
  State<_RepoTile> createState() => _RepoTileState();
}

class _RepoTileState extends State<_RepoTile> {
  @override
  Widget build(BuildContext context) {
    // final model = context.watch<PackageUpdatesModel>();
    return YaruTile(
      subtitle: Text(context.l10n.sourcesDescription),
      trailing: OutlinedButton(
        onPressed: () =>
            Utils.settingsNav.currentState!.pushNamed('/repoDialog'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
            ),
            const Icon(
              YaruIcons.settings,
              size: 18,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(context.l10n.configure),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsModel>();

    return YaruTile(
      title: Text(
        '${context.l10n.version}: ${model.version} ${model.buildNumber}',
      ),
      trailing: OutlinedButton(
        onPressed: () => Utils.settingsNav.currentState!.pushNamed('/about'),
        child: Text(context.l10n.contributors),
      ),
    );
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsModel>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YaruDialogTitleBar(
            leading: YaruBackButton(
              style: YaruBackButtonStyle.rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: kYaruPagePadding,
                bottom: kYaruPagePadding,
                left: 40,
                right: 40,
              ),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/software.png',
                      width: 100,
                      height: 100,
                      filterQuality: FilterQuality.medium,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.appName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '${context.l10n.version} ${model.version} ${model.buildNumber}',
                          ),
                          InkWell(
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
                                      .bodyMedium
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                FutureBuilder<String>(
                  future: loadAsset(context),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return MarkdownBody(
                        data: '${context.l10n.madeBy}:\n ${snapshot.data!}',
                        onTapLink: (text, href, title) =>
                            href != null ? launchUrl(Uri.parse(href)) : null,
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/contributors.md');
  }
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile();

  @override
  Widget build(BuildContext context) {
    return YaruTile(
      title: Link(
        linkText: '${context.l10n.license}: GPL3',
        url: 'https://www.gnu.org/licenses/gpl-3.0.de.html',
        textStyle: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: OutlinedButton(
        onPressed: () => Utils.settingsNav.currentState!.pushNamed('/licenses'),
        child: Text(context.l10n.packagesUsed),
      ),
      enabled: true,
    );
  }
}

class _LicensePage extends StatelessWidget {
  const _LicensePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          YaruDialogTitleBar(),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                pageTransitionsTheme:
                    YaruMasterDetailTheme.of(context).landscapeTransitions,
              ),
              child: const LicensePage(),
            ),
          ),
        ],
      ),
    );
  }
}

class Utils {
  static GlobalKey<NavigatorState> settingsNav = GlobalKey();
  static GlobalKey<NavigatorState> repoNav = GlobalKey();
  static GlobalKey<NavigatorState> aboutNav = GlobalKey();
}
