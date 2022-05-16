import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  static Widget createTitle(BuildContext context) => Text('Settings');

  @override
  Widget build(BuildContext context) {
    return YaruPage(children: [
      YaruRow(
        trailingWidget: Text('Software'),
        actionWidget: TextButton(
            onPressed: () => showAboutDialog(context: context),
            child: Text('Show About Dialog')),
        enabled: true,
        width: 500,
      )
    ]);
  }
}
