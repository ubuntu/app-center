import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/deb_installer/deb_installer_model.dart';
import 'package:software/deb_installer/wizard_page.dart';
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

    return WizardPage(
      title: const Text('Debian Package installer'),
      actions: [
        model.installationComplete
            ? ElevatedButton(
                onPressed: () => model.remove(),
                child: const Text('Remove'),
              )
            : ElevatedButton(
                onPressed: () => model.install(),
                child: const Text('Install'),
              ),
      ],
      content: Center(
        child: SingleChildScrollView(
          child: Row(
            children: [
              const SizedBox(
                width: 8,
              ),
              YaruSection(
                width: MediaQuery.of(context).size.width / 2,
                children: [
                  YaruSingleInfoRow(infoLabel: 'Name', infoValue: model.name),
                  const SizedBox(
                    height: 10,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: 'Version',
                    infoValue: model.version,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  YaruSingleInfoRow(infoLabel: 'Arch', infoValue: model.arch),
                  const SizedBox(
                    height: 10,
                  ),
                  YaruSingleInfoRow(infoLabel: 'Data', infoValue: model.data),
                  const SizedBox(
                    height: 10,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: 'License',
                    infoValue: model.license,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: 'Size',
                    infoValue: model.size.toString(),
                  ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 145,
                      height: 185,
                      child: LiquidLinearProgressIndicator(
                        value: model.progress.toDouble(),
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).primaryColor,
                        ),
                        direction: Axis.vertical,
                        borderRadius: 20,
                      ),
                    ),
                    Icon(
                      YaruIcons.debian,
                      size: 120,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
