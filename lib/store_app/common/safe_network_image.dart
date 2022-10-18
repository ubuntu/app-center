import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitHeight,
  });

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(
      YaruIcons.image,
      size: 60,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
    );
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
