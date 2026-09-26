import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/store/store_navigator.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.settings_filled : YaruIcons.settings;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).settingsPageLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverToBoxAdapter(
            child: YaruTileList(
              children: [
                YaruListTile.square(
                  titleText: l10n.settingsPageAboutLabel,
                  trailing: const Icon(YaruIcons.go_next),
                  onTap: () => StoreNavigator.pushAbout(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
