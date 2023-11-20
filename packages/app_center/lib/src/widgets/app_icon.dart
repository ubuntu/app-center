import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '/constants.dart';
import '/layout.dart';
import '/xdg_cache_manager.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.iconUrl,
    this.size = kIconSize,
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
              child: CachedNetworkImage(
                cacheManager: XdgCacheManager(),
                fadeInDuration: const Duration(milliseconds: 100),
                fadeOutDuration: const Duration(milliseconds: 200),
                imageUrl: iconUrl!,
                imageBuilder: (context, imageProvider) => Image(
                  image: imageProvider,
                  filterQuality: FilterQuality.medium,
                  fit: BoxFit.fitHeight,
                ),
                placeholder: (context, url) => fallBackLoadingIcon,
                errorWidget: (context, url, error) => fallBackIcon,
              ),
            ),
    );
  }
}
