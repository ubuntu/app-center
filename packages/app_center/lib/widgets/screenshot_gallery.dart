import 'package:app_center/xdg_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaru/yaru.dart';

class ScreenshotGallery extends StatelessWidget {
  const ScreenshotGallery({
    required this.title,
    required this.urls,
    super.key,
    this.height,
  });

  final String title;
  final List<String> urls;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return YaruCarousel(
      height: height ?? 500,
      width: double.infinity,
      nextIcon: const Icon(YaruIcons.go_next),
      previousIcon: const Icon(YaruIcons.go_previous),
      navigationControls: urls.length > 1,
      children: [
        for (int i = 0; i < urls.length; i++)
          MediaTile(
            url: urls[i],
            onTap: () => showDialog(
              context: context,
              builder: (_) => _CarouselDialog(
                title: title,
                urls: urls,
                initialIndex: i,
              ),
            ),
          ),
      ],
    );
  }
}

class MediaTile extends StatelessWidget {
  const MediaTile({
    required this.url,
    required this.onTap,
    super.key,
    this.fit = BoxFit.contain,
  });

  final String url;
  final BoxFit fit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(10));
    const padding = EdgeInsets.all(5);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius.outer(padding),
          excludeFromSemantics: true,
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: SafeNetworkImage(
                url: url,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarouselDialog extends StatefulWidget {
  const _CarouselDialog({
    required this.title,
    required this.urls,
    required this.initialIndex,
  });

  final String title;
  final List<String> urls;
  final int initialIndex;

  @override
  State<_CarouselDialog> createState() => _CarouselDialogState();
}

class _CarouselDialogState extends State<_CarouselDialog> {
  late YaruCarouselController controller;

  @override
  void initState() {
    super.initState();
    controller = YaruCarouselController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
          controller.nextPage();
        } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          controller.previousPage();
        }
      },
      child: SimpleDialog(
        title: YaruDialogTitleBar(
          title: Text(widget.title),
        ),
        contentPadding: const EdgeInsets.only(bottom: 20, top: 20),
        titlePadding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: size.height - 150,
            width: size.width,
            child: YaruCarousel(
              controller: controller,
              nextIcon: const Icon(YaruIcons.go_next),
              previousIcon: const Icon(YaruIcons.go_previous),
              navigationControls: widget.urls.length > 1,
              width: size.width,
              placeIndicatorMarginTop: 20.0,
              children: [
                for (final url in widget.urls)
                  SafeNetworkImage(
                    url: url,
                    fit: BoxFit.fitWidth,
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    required this.url,
    super.key,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitHeight,
    this.fallBackIcon,
  });

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final Widget? fallBackIcon;

  @override
  Widget build(BuildContext context) {
    final fallBack = fallBackIcon ??
        Icon(
          YaruIcons.image,
          size: 60,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        );
    if (url == null) return fallBack;
    return CachedNetworkImage(
      cacheManager: XdgCacheManager(),
      fadeInDuration: const Duration(milliseconds: 100),
      fadeOutDuration: const Duration(milliseconds: 200),
      imageUrl: url!,
      imageBuilder: (context, imageProvider) => Image(
        image: imageProvider,
        filterQuality: filterQuality,
        fit: fit,
      ),
      placeholder: (context, url) => fallBack,
      errorWidget: (context, url, error) => fallBack,
    );
  }
}
