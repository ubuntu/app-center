import 'package:flutter/material.dart';

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
