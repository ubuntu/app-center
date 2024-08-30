import 'package:app_center/games/games.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/widgets/app_card.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

class SnapMenuItem extends StatelessWidget {
  const SnapMenuItem({
    required this.title,
    required this.onPressed,
    this.textStyle,
    super.key,
  });

  final String title;
  final void Function() onPressed;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onPressed,
      child: IntrinsicWidth(
        child: ListTile(
          mouseCursor: SystemMouseCursors.click,
          title: Text(
            title,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
