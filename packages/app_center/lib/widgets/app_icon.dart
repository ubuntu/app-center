import 'dart:io';

import 'package:app_center/appstream/appstream_utils.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/xdg_cache_manager.dart';
import 'package:appstream/appstream.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/icons.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.iconUrl,
    super.key,
    this.size = kIconSize,
    this.loadingHighlight,
    this.loadingBaseColor,
  });

  final String? iconUrl;
  final double size;
  final Color? loadingHighlight;
  final Color? loadingBaseColor;

  bool get _isLocalPath =>
      iconUrl != null &&
      iconUrl!.isNotEmpty &&
      !iconUrl!.startsWith('http://') &&
      !iconUrl!.startsWith('https://');

  bool get _isSvg => iconUrl != null && iconUrl!.endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final fallBackIcon = YaruPlaceholderIcon(size: Size.square(size));

    final light = Theme.of(context).brightness == Brightness.light;
    final fallBackLoadingIcon = Shimmer.fromColors(
      baseColor:
          loadingBaseColor ?? (light ? kShimmerBaseLight : kShimmerBaseDark),
      highlightColor: loadingHighlight ??
          (light ? kShimmerHighLightLight : kShimmerHighLightDark),
      child: fallBackIcon,
    );

    if (iconUrl == null || iconUrl!.isEmpty) {
      return fallBackIcon;
    }

    if (_isLocalPath) {
      return RepaintBoundary(
        child: SizedBox(
          height: size,
          width: size,
          child: _isSvg
              ? SvgPicture.file(
                  File(iconUrl!),
                  placeholderBuilder: (_) => fallBackIcon,
                )
              : Image.file(
                  File(iconUrl!),
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, error, stackTrace) => fallBackIcon,
                ),
        ),
      );
    }

    return RepaintBoundary(
      child: SizedBox(
        height: size,
        width: size,
        child: CachedNetworkImage(
          cacheManager: XdgCacheManager(),
          fadeInDuration: const Duration(milliseconds: 100),
          fadeOutDuration: const Duration(milliseconds: 200),
          imageUrl: iconUrl!,
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
            fit: BoxFit.fitHeight,
          ),
          placeholder: (context, url) => fallBackLoadingIcon,
          errorWidget: (context, url, error) => fallBackIcon,
        ),
      ),
    );
  }
}

/// An icon widget for deb packages that resolves the themed icon path
/// asynchronously and shows a placeholder while the path is being looked up.
///
/// This is useful for apps like Nautilus or the terminal where we want to
/// display the local theme icon for the app instead of the upstream icon.
class DebAppIcon extends StatelessWidget {
  const DebAppIcon({
    required this.component,
    super.key,
    this.size = kIconSize,
    this.loadingHighlight,
    this.loadingBaseColor,
  });

  final AppstreamComponent component;
  final double size;
  final Color? loadingHighlight;
  final Color? loadingBaseColor;

  @override
  Widget build(BuildContext context) {
    final fallBackIcon = YaruPlaceholderIcon(size: Size.square(size));

    return FutureBuilder<String?>(
      future: component.iconAsync,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return RepaintBoundary(
            child: SizedBox(
              height: size,
              width: size,
              child: fallBackIcon,
            ),
          );
        }

        return AppIcon(
          iconUrl: snapshot.data,
          size: size,
          loadingHighlight: loadingHighlight,
          loadingBaseColor: loadingBaseColor,
        );
      },
    );
  }
}
