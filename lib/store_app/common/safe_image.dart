import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SafeImage extends StatelessWidget {
  const SafeImage({
    Key? key,
    required this.url,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitHeight,
    this.fallBackIconData = YaruIcons.image,
    this.iconSize = 65,
  }) : super(key: key);

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final IconData fallBackIconData;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(fallBackIconData, size: iconSize);
    if (url == null) return fallbackIcon;
    return Image.network(
      url!,
      filterQuality: filterQuality,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return frame == null ? fallbackIcon : child;
      },
      errorBuilder: (context, error, stackTrace) => fallbackIcon,
    );
  }
}
