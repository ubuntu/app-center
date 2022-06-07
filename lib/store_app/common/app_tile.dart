import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  const AppTile({
    Key? key,
    this.onTap,
    required this.icon,
  }) : super(key: key);

  final Function()? onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).cardColor
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: icon,
      ),
    );
  }
}
