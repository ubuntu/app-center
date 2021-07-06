import 'package:flutter/widgets.dart';

class PageItem {
  PageItem(
      {required this.title,
      required this.builder,
      required this.iconData,
      this.selectedIconData});
  final String title;
  final WidgetBuilder builder;
  final IconData iconData;
  IconData? selectedIconData;
}
