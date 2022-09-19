import 'package:flutter/material.dart';
import 'package:software/store_app/common/constants.dart';

class BorderContainer extends StatelessWidget {
  const BorderContainer({
    super.key,
    this.height,
    this.width,
    this.padding,
    this.child,
  });

  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: const EdgeInsets.all(pagePadding),
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: child,
    );

    return padding != null
        ? Padding(
            padding: padding!,
            child: container,
          )
        : container;
  }
}
