import 'package:flutter/material.dart';
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
