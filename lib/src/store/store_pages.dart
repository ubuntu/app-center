import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/about.dart';
import '/category.dart';
import '/explore.dart';
import '/manage.dart';

typedef StorePage = ({
  Widget Function(BuildContext context, bool selected) tileBuilder,
  WidgetBuilder pageBuilder,
});

final pages = <StorePage>[
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(ExplorePage.icon(selected)),
          title: Text(ExplorePage.label(context)),
        ),
    pageBuilder: (_) => const ExplorePage(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(ProductivityPage.icon(selected)),
          title: Text(ProductivityPage.label(context)),
        ),
    pageBuilder: (_) => const ProductivityPage(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(DevelopmentPage.icon(selected)),
          title: Text(DevelopmentPage.label(context)),
        ),
    pageBuilder: (_) => const DevelopmentPage(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(GamesPage.icon(selected)),
          title: Text(GamesPage.label(context)),
        ),
    pageBuilder: (_) => const GamesPage(),
  ),
  (
    tileBuilder: (context, selected) => const Spacer(),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    tileBuilder: (context, selected) => const Divider(height: 1),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(ManagePage.icon(selected)),
          title: Text(ManagePage.label(context)),
        ),
    pageBuilder: (_) => const ManagePage(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(AboutPage.icon(selected)),
          title: Text(AboutPage.label(context)),
        ),
    pageBuilder: (_) => const AboutPage(),
  ),
];
