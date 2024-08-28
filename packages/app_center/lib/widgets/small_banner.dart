import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

/// Slimmer version (no border or description) of the [YaruBanner].
class SmallBanner extends StatelessWidget {
  const SmallBanner({required this.child, super.key, this.onTap});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(kYaruBannerRadius);
    final light = theme.brightness == Brightness.light;
    final defaultSurfaceTintColor =
        light ? theme.cardColor : const Color.fromARGB(255, 126, 126, 126);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.transparent,
        child: Card(
          color: theme.cardColor,
          shadowColor: Colors.transparent,
          surfaceTintColor: defaultSurfaceTintColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius.inner(const EdgeInsets.all(4.0)),
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
