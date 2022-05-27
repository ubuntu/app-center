import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/settings/settings_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SettingsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return YaruPage(children: [
      YaruRow(
        trailingWidget: const Text('Software'),
        actionWidget: TextButton(
            onPressed: () => showAboutDialog(context: context),
            child: const Text('Show About Dialog')),
        enabled: true,
        width: 500,
      )
    ]);
  }
}
