import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/about.dart';
import '/category.dart';
import '/constants.dart';
import '/explore.dart';
import '/manage.dart';

typedef StorePage = ({
  Widget Function(BuildContext context, bool selected) itemBuilder,
  WidgetBuilder pageBuilder,
});

Widget buildNaviRailItem({required IconData icon, required String label}) {
  return YaruNavigationRailItem(
    icon: Icon(icon),
    label: Text(label),
    style: YaruNavigationRailStyle.labelledExtended,
    width: kNaviRailWidth,
  );
}

final pages = <StorePage>[
  (
    itemBuilder: (context, selected) => buildNaviRailItem(
          icon: ExplorePage.icon(selected),
          label: ExplorePage.label(context),
        ),
    pageBuilder: (_) => const ExplorePage(),
  ),
  (
    itemBuilder: (context, selected) => buildNaviRailItem(
          icon: ProductivityPage.icon(selected),
          label: ProductivityPage.label(context),
        ),
    pageBuilder: (_) => const ProductivityPage(),
  ),
  (
    itemBuilder: (context, selected) => buildNaviRailItem(
          icon: DevelopmentPage.icon(selected),
          label: DevelopmentPage.label(context),
        ),
    pageBuilder: (_) => const DevelopmentPage(),
  ),
  (
    itemBuilder: (context, selected) => buildNaviRailItem(
          icon: GamesPage.icon(selected),
          label: GamesPage.label(context),
        ),
    pageBuilder: (_) => const GamesPage(),
  ),
  (
    itemBuilder: (context, selected) => const Spacer(flex: 2 << 53),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    itemBuilder: (context, selected) => const SizedBox(
          width: kNaviRailWidth,
          child: Divider(height: 1),
        ),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    itemBuilder: (context, selected) => buildNaviRailItem(
          icon: ManagePage.icon(selected),
          label: ManagePage.label(context),
        ),
    pageBuilder: (_) => const ManagePage(),
  ),
  (
    itemBuilder: (context, selected) => buildNaviRailItem(
          icon: AboutPage.icon(selected),
          label: AboutPage.label(context),
        ),
    pageBuilder: (_) => const AboutPage(),
  ),
];
