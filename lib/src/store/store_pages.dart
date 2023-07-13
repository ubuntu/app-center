import 'package:flutter/widgets.dart';

import '/category.dart';
import '/explore.dart';
import '/manage.dart';

typedef StorePage = ({
  IconData Function(bool) icon,
  String Function(BuildContext) labelBuilder,
  WidgetBuilder builder
});

final pages = <StorePage>[
  (
    icon: ExplorePage.icon,
    labelBuilder: ExplorePage.label,
    builder: (_) => const ExplorePage(),
  ),
  (
    icon: ProductivityPage.icon,
    labelBuilder: ProductivityPage.label,
    builder: (_) => const ProductivityPage(),
  ),
  (
    icon: DevelopmentPage.icon,
    labelBuilder: DevelopmentPage.label,
    builder: (_) => const DevelopmentPage(),
  ),
  (
    icon: GamesPage.icon,
    labelBuilder: GamesPage.label,
    builder: (_) => const GamesPage(),
  ),
  (
    icon: ManagePage.icon,
    labelBuilder: ManagePage.label,
    builder: (_) => const ManagePage(),
  ),
];
