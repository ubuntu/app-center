import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/settings/settings_model.dart';
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
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return YaruPage(
              children: [
                YaruRow(
                  trailingWidget: const Text('Software v0.0.1-alpha'),
                  actionWidget: TextButton(
                    onPressed: () {
                      showAboutDialog(
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
