import 'package:flutter/material.dart';

class BasePlate extends StatelessWidget {
  const BasePlate({
    super.key,
    required this.child,
    required this.hovered,
    this.radius = 10.0,
    this.blurRadius = 5,
    this.spreadRadius = 3,
    this.useBorder = false,
  });

  final Widget child;
  final bool hovered;
  final double radius;
  final int spreadRadius;
  final int blurRadius;
  final bool useBorder;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: useBorder
            ? Border.all(width: 1, color: Theme.of(context).dividerColor)
            : null,
        boxShadow: useBorder
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(hovered ? 0.4 : 0.15),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}
