import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '/widgets.dart';

class SnapIcon extends StatelessWidget {
  const SnapIcon({
    super.key,
    required this.iconUrl,
    this.size = 48,
    this.loadingHighlight,
    this.loadingBaseColor,
  });

  final String? iconUrl;
  final double size;
  final Color? loadingHighlight;
  final Color? loadingBaseColor;

  @override
  Widget build(BuildContext context) {
    final fallBackIcon = YaruPlaceholderIcon(size: Size.square(size));

    var light = Theme.of(context).brightness == Brightness.light;
    final fallBackLoadingIcon = Shimmer.fromColors(
      baseColor:
          loadingBaseColor ?? (light ? kShimmerBaseLight : kShimmerBaseDark),
      highlightColor: loadingHighlight ??
          (light ? kShimmerHighLightLight : kShimmerHighLightDark),
      child: fallBackIcon,
    );

    return RepaintBoundary(
      child: iconUrl == null || iconUrl!.isEmpty
          ? fallBackIcon
          : SizedBox(
              height: size,
              width: size,
              child: Image.network(
                iconUrl!,
                filterQuality: FilterQuality.medium,
                fit: BoxFit.fitHeight,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: frame == null ? fallBackLoadingIcon : child,
                  );
                },
                errorBuilder: (context, url, error) => fallBackIcon,
              ),
            ),
    );
  }
}
