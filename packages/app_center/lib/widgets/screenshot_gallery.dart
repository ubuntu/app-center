import 'package:app_center/l10n.dart';
import 'package:app_center/xdg_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';

class ScreenshotGallery extends StatefulWidget {
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
  State<ScreenshotGallery> createState() => _ScreenshotGalleryState();
}

class _ScreenshotGalleryState extends State<ScreenshotGallery> {
  final _controller = YaruCarouselController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        YaruCarousel(
          controller: _controller,
          height: widget.height ?? 500,
          width: double.infinity,
          children: [
            for (int i = 0; i < widget.urls.length; i++)
              MediaTile(
                url: widget.urls[i],
                semanticLabel: l10n.snapPageGalleryImageSemanticLabel(i + 1),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => _CarouselDialog(
                    title: widget.title,
                    urls: widget.urls,
                    initialIndex: i,
                  ),
                ),
              ),
          ],
        ),
        _DirectionalNavigationControls(
          controller: _controller,
          itemCount: widget.urls.length,
          bottomOffset: 36,
        ),
      ],
    );
  }
}

class MediaTile extends StatelessWidget {
  const MediaTile({
    required this.url,
    required this.onTap,
    required this.semanticLabel,
    super.key,
    this.fit = BoxFit.contain,
  });

  final String url;
  final String semanticLabel;
  final BoxFit fit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(10));
    const padding = EdgeInsets.all(5);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          button: true,
          child: YaruFocusBorder.primary(
            borderRadius: borderRadius.outer(padding),
            child: InkWell(
              borderRadius: borderRadius.outer(padding),
              focusColor: Colors.transparent,
              excludeFromSemantics: true,
              onTap: onTap,
              child: Padding(
                padding: padding,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: SafeNetworkImage(
                    url: url,
                    semanticLabel: semanticLabel,
                  ),
                ),
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
  late final _controller = YaruCarouselController(
    initialPage: widget.initialIndex,
  );
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (value) {
        if (value is! KeyDownEvent) return;
        if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
          isRtl ? _controller.previousPage() : _controller.nextPage();
        } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          isRtl ? _controller.nextPage() : _controller.previousPage();
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: YaruCarousel(
                    controller: _controller,
                    height: size.height - 150,
                    width: size.width,
                    placeIndicatorMarginTop: 20.0,
                    children: [
                      for (int i = 0; i < widget.urls.length; i++)
                        SafeNetworkImage(
                          url: widget.urls[i],
                          fit: BoxFit.contain,
                          semanticLabel: l10n.snapPageGalleryImageSemanticLabel(
                            i + 1,
                          ),
                        ),
                    ],
                  ),
                ),
                _DirectionalNavigationControls(
                  controller: _controller,
                  itemCount: widget.urls.length,
                  bottomOffset: 40,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionalNavigationControls extends StatelessWidget {
  const _DirectionalNavigationControls({
    required this.controller,
    required this.itemCount,
    required this.bottomOffset,
  });

  final YaruCarouselController controller;
  final int itemCount;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final page = controller.hasClients
            ? (controller.page ?? controller.initialPage).round()
            : controller.initialPage;
        final isFirst = page <= 0;
        final isLast = page >= itemCount - 1;

        return Positioned(
          top: 0,
          bottom: bottomOffset,
          left: 0,
          right: 0,
          child: Stack(
            children: [
              _buildButton(
                context: context,
                alignment: AlignmentDirectional.centerStart,
                onPressed: isFirst ? null : controller.previousPage,
                icon: Icon(
                  isRtl ? YaruIcons.go_next : YaruIcons.go_previous,
                  semanticLabel: l10n.snapPageGalleryPreviousSemanticLabel,
                ),
              ),
              _buildButton(
                context: context,
                alignment: AlignmentDirectional.centerEnd,
                onPressed: isLast ? null : controller.nextPage,
                icon: Icon(
                  isRtl ? YaruIcons.go_previous : YaruIcons.go_next,
                  semanticLabel: l10n.snapPageGalleryNextSemanticLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required AlignmentGeometry alignment,
    required VoidCallback? onPressed,
    required Widget icon,
  }) {
    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      onPressed: onPressed,
      child: icon,
    );

    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        opacity: onPressed != null ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: (YaruTheme.maybeOf(context)?.focusBorders ?? false)
            ? YaruFocusBorder.primary(child: button)
            : button,
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
    this.semanticLabel,
  });

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final Widget? fallBackIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fallBack =
        fallBackIcon ??
        Icon(
          YaruIcons.image,
          size: 60,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
        semanticLabel: semanticLabel,
      ),
      placeholder: (context, url) => fallBack,
      errorWidget: (context, url, error) => fallBack,
    );
  }
}
