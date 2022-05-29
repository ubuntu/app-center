import 'package:dpkg/dpkg.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class DebInstallerApp extends StatelessWidget {
  const DebInstallerApp({Key? key, required this.debBinaryFile})
      : super(key: key);

  final DebBinaryFile debBinaryFile;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: YaruTheme(
        child: FutureBuilder<DebControl>(
          future: getControl(debBinaryFile),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final control = snapshot.data!;
              return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      control.package,
                    ),
                  ),
                  body: YaruPage(children: [
                    YaruSection(
                      width: 650,
                      children: [
                        YaruRow(
                          trailingWidget: Text(control.version),
                          actionWidget: ElevatedButton(
                              onPressed: () {}, child: const Text('Install')),
                          enabled: true,
                        ),
                      ],
                    )
                  ]));
            } else {
              return const Center(
                child: YaruCircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<DebControl>? getControl(DebBinaryFile debBinaryFile) async {
    return await debBinaryFile.getControl();
  }
}
