import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_software_store/pages/my_apps_page.dart';
import 'package:ubuntu_software_store/pages/page_items.dart';
import 'package:ubuntu_software_store/view/layout/narrow_layout.dart';
import 'package:ubuntu_software_store/view/layout/wide_layout.dart';
import 'package:yaru/yaru.dart' as yaru;
import 'package:yaru_icons/widgets/yaru_icons.dart';

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
    PageItem(
        title: 'Explore',
        builder: (_) => Text('Explore'),
        iconData: YaruIcons.search),
    PageItem(
        title: 'My Apps',
        builder: (_) => MyAppsPage(),
        iconData: YaruIcons.app_grid),
    PageItem(
        title: 'Updates',
        builder: (_) => Text('Updates'),
        iconData: YaruIcons.save),
  ];

  UbuntuStoreApp({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: yaru.lightTheme,
      darkTheme: yaru.darkTheme,
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return WideLayout(
                pageItems: pageItems,
              );
            } else {
              return NarrowLayout(
                pageItems: pageItems,
              );
            }
          },
        ),
      ),
    );
  }
}
