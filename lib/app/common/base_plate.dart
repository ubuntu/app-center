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
    this.useShadow = true,
    this.childPadding = 10.0,
  });

  final Widget child;
  final bool hovered;
  final double radius;
  final double spreadRadius;
  final double blurRadius;
  final bool useBorder;
  final bool useShadow;
  final double childPadding;

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
        boxShadow: useShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(hovered ? 0.4 : 0.15),
                  spreadRadius: spreadRadius,
                  blurRadius: blurRadius,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(childPadding),
        child: child,
      ),
    );
  }
}
