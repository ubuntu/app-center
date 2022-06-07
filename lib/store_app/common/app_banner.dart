import 'package:flutter/material.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
    required this.color,
    required this.title,
    required this.summary,
    required this.elevation,
    required this.icon,
    required this.borderRadius,
    required this.textOverflow,
  }) : super(key: key);

  final Color color;
  final String title;
  final String summary;
  final double elevation;
  final Widget icon;
  final BorderRadius borderRadius;
  final TextOverflow textOverflow;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 370,
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            subtitle: Text(summary, overflow: textOverflow),
            title: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            leading: SizedBox(
              width: 60,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
