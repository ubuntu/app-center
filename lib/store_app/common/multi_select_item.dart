import 'package:flutter/material.dart';

class MultiSelectItem<T> extends StatefulWidget {
  const MultiSelectItem({
    super.key,
    required this.values,
    required this.value,
    this.contentPadding = const EdgeInsets.only(left: 15),
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final Set<T> values;
  final void Function() onTap;
  final T value;
  final Widget child;
  final EdgeInsets contentPadding;
  final bool enabled;

  @override
  State<MultiSelectItem> createState() => _MultiSelectItemState();
}

class _MultiSelectItemState extends State<MultiSelectItem> {
  @override
  Widget build(BuildContext context) {
    final textColor = widget.enabled
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).disabledColor;
    final borderColor = Theme.of(context).colorScheme.onSurface.withOpacity(
          Theme.of(context).brightness == Brightness.light ? 0.4 : 1,
        );
    return ListTile(
      visualDensity: VisualDensity.compact,
      enabled: widget.enabled,
      contentPadding: widget.contentPadding,
      onTap: () {
        setState(() {
          widget.onTap();
        });
      },
      leading: widget.values.contains(widget.value)
          ? AnimatedContainer(
              height: 18,
              width: 18,
              duration: const Duration(
                milliseconds: 200,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              ),
            )
          : AnimatedContainer(
              height: 18,
              width: 18,
              duration: const Duration(
                milliseconds: 200,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
      title: DefaultTextStyle(
        style: TextStyle(color: textColor, fontSize: 16),
        child: widget.child,
      ),
    );
  }
}
