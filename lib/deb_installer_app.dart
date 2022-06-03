import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/deb_installer_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class DebInstallerApp extends StatefulWidget {
  const DebInstallerApp({
    Key? key,
  }) : super(key: key);

  static Widget create(String debFileName) {
    return ChangeNotifierProvider(
      create: (context) =>
          DebInstallerModel(debFileName, getService<PackageKitClient>()),
      child: const DebInstallerApp(),
    );
  }

  @override
  State<DebInstallerApp> createState() => _DebInstallerAppState();
}

class _DebInstallerAppState extends State<DebInstallerApp> {
  @override
  void initState() {
    super.initState();
    final model = context.read<DebInstallerModel>();
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DebInstallerModel>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: YaruTheme(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              model.packageName,
            ),
          ),
          body: YaruPage(
            children: [
              Center(
                child: YaruSection(
                  width: 500,
                  children: [
                    YaruRow(
                      trailingWidget: Text(model.version),
                      actionWidget: ElevatedButton(
                        onPressed: () => model.install(),
                        child: Text(context.l10n.install),
                      ),
                      enabled: true,
                    ),
                    YaruLinearProgressIndicator(
                      value: model.progress.toDouble(),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
