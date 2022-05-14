import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/my_apps_page.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

void main() async {
  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => SnapdClient()),
    ],
    child: UbuntuStoreApp(title: 'Ubuntu Software App'),
  ));
}

class UbuntuStoreApp extends StatelessWidget {
  final String title;

  final pageItems = [
    YaruPageItem(
        titleBuilder: (context) => Text('My Apps'),
        builder: (_) => MyAppsPage(),
        iconData: YaruIcons.app_grid),
    YaruPageItem(
        titleBuilder: (context) => Text('Explore'),
        builder: (_) => Center(child: Text('Explore')),
        iconData: YaruIcons.search),
    YaruPageItem(
        titleBuilder: (context) => Text('Updates'),
        builder: (_) => Center(child: Text('Updates')),
        iconData: YaruIcons.save),
  ];

  UbuntuStoreApp({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: YaruTheme(
        child: Scaffold(
          body: YaruCompactLayout(
            pageItems: pageItems,
          ),
        ),
      ),
    );
  }
}
