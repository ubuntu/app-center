import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '/l10n.dart';
import 'category_page.dart';

class ProductivityPage extends CategoryPage {
  const ProductivityPage({super.key}) : super(category: 'productivity');

  static IconData icon(bool selected) =>
      selected ? YaruIcons.send_filled : YaruIcons.send;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).productivityPageLabel;
}
