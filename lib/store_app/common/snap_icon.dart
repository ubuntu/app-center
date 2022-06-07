import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:software/snapx.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SnapIcon extends StatelessWidget {
  const SnapIcon(
    this.snap, {
    Key? key,
  }) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    const fallbackIcon = Icon(YaruIcons.package_snap, size: 65);
    if (snap.iconUrl == null) return fallbackIcon;
    return Image.network(
      snap.iconUrl!,
      filterQuality: FilterQuality.medium,
      fit: BoxFit.fitHeight,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return frame == null ? fallbackIcon : child;
      },
      errorBuilder: (context, error, stackTrace) => fallbackIcon,
    );
  }
}
