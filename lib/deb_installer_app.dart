import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/deb_installer_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class DebInstallerApp extends StatelessWidget {
  const DebInstallerApp({Key? key, required this.filename}) : super(key: key);

  final String filename;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // supportedLocales: AppLocalizations.supportedLocales,
      // onGenerateTitle: (context) => context.l10n.appTitle,
      routes: {
        Navigator.defaultRouteName: (context) =>
            YaruTheme(child: DebInstallerPage.create(filename))
      },
    );
  }
}

class DebInstallerPage extends StatefulWidget {
  const DebInstallerPage({super.key});

  static Widget create(String debFileName) {
    return ChangeNotifierProvider(
      create: (context) =>
          DebInstallerModel(debFileName, getService<PackageKitClient>()),
      child: const DebInstallerPage(),
    );
  }

  @override
  State<DebInstallerPage> createState() => _DebInstallerPageState();
}

class _DebInstallerPageState extends State<DebInstallerPage> {
  @override
  void initState() {
    super.initState();
    final model = context.read<DebInstallerModel>();
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DebInstallerModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deb Installer',
        ),
      ),
      body: Center(
        child: YaruPage(
          children: [
            YaruSection(
              width: 500,
              children: [
                YaruRow(
                  trailingWidget: Text('${model.packageName} ${model.version}'),
                  actionWidget: model.installationComplete
                      ? ElevatedButton(
                          onPressed: () {},
                          child: const Text('Remove'),
                        )
                      : ElevatedButton(
                          onPressed: () => model.install(),
                          child: const Text('Install'),
                        ),
                  enabled: true,
                ),
                if (model.status.isNotEmpty && !model.installationComplete)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      model.status,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                if (model.progress != 0)
                  YaruLinearProgressIndicator(
                    value: model.progress.toDouble(),
                  )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  YaruIcons.package_deb,
                  size: 200,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                Icon(
                  YaruIcons.package_deb,
                  size: 200,
                  color:
                      Theme.of(context).primaryColor.withAlpha(model.progress),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
