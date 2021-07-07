import 'package:flutter/material.dart';
import 'package:ubuntu_software_store/pages/page_items.dart';
import 'package:ubuntu_software_store/view/layout/narrow_layout.dart';
import 'package:ubuntu_software_store/view/layout/wide_layout.dart';
import 'package:yaru/yaru.dart' as yaru;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ubuntu Store Flutter',
      theme: yaru.lightTheme,
      darkTheme: yaru.darkTheme,
      home: UbuntuStoreApp(title: 'Ubuntu Store Flutter Home Page'),
    );
  }
}

class UbuntuStoreApp extends StatelessWidget {
  final String title;

  const UbuntuStoreApp({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: yaru.lightTheme,
      darkTheme: yaru.darkTheme,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final pageItems = [
    PageItem(
        title: 'Explore',
        builder: (_) => Text('Explore'),
        iconData: Icons.explore),
    PageItem(
        title: 'My Apps',
        builder: (_) => Text('My Apps'),
        iconData: Icons.apps),
    PageItem(
        title: 'Updates',
        builder: (_) => Text('Updates'),
        iconData: Icons.system_update_alt),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
