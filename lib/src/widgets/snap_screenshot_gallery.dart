import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/snapd.dart';

class SnapScreenshotGallery extends StatelessWidget {
  const SnapScreenshotGallery({super.key, required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    return YaruCarousel(
      height: 350,
      nextIcon: const Icon(YaruIcons.go_next),
      previousIcon: const Icon(YaruIcons.go_previous),
      navigationControls: snap.screenshotUrls.length > 1,
      children: [
        for (int i = 0; i < snap.screenshotUrls.length; i++)
          MediaTile(
            url: snap.screenshotUrls[i],
            onTap: () => showDialog(
              context: context,
              builder: (_) => _CarouselDialog(
                title: snap.titleOrName,
                urls: snap.screenshotUrls,
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
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    required this.onTap,
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
      viewportFraction: 0.8,
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
    super.key,
    required this.url,
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
    return Image.network(
      url!,
      filterQuality: filterQuality,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return frame == null ? fallBack : child;
      },
      errorBuilder: (context, error, stackTrace) => fallBack,
    );
  }
}
