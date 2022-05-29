import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final IconData iconData;
  final bool selected;
  final Function()? onPressed;
  final String? tooltip;

  const FilterButton({
    Key? key,
    required this.selected,
    required this.iconData,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: selected
          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.05)
          : Colors.transparent,
      child: IconButton(
        tooltip: tooltip,
        color: selected ? Colors.grey : null,
        splashRadius: 20,
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }
}
