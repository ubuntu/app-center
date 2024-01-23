import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/store/store_pages.dart';
import 'package:app_center/store.dart';
import 'package:app_center/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';

class CategoryBanner extends ConsumerWidget {
  const CategoryBanner({
    required this.category,
    this.padding = 48,
    this.height = 240,
    this.kMaxSize = 88.0,
    this.kIconSize = 48.0,
    this.kNumberOfBannerSnaps = 3,
    super.key,
  });

  final SnapCategoryEnum category;
  final double padding;
  final double height;
  final double kMaxSize;
  final double kIconSize;
  final int kNumberOfBannerSnaps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snaps = ref
        .watch(snapSearchProvider(SnapSearchParameters(category: category)))
        .whenOrNull(data: (data) => data);
    final featuredSnaps = category.featuredSnapNames != null
        ? category.featuredSnapNames!
            .map(
                (name) => snaps?.singleWhereOrNull((snap) => snap.name == name))
            .whereNotNull()
        : snaps;
    final l10n = AppLocalizations.of(context);
    return _Banner(
      snaps: featuredSnaps?.take(kNumberOfBannerSnaps).toList() ?? [],
      slogan: category.slogan(l10n),
      buttonLabel: category.buttonLabel(l10n),
      onPressed: () {
        if (displayedCategories.contains(category)) {
          ref.read(yaruPageControllerProvider).index =
              displayedCategories.indexOf(category) + 1;
        } else {
          StoreNavigator.pushSearch(context, category: category.categoryName);
        }
      },
      colors: category.bannerColors,
      padding: padding,
      height: height,
      kMaxSize: kMaxSize,
      kIconSize: kIconSize,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.snaps,
    required this.slogan,
    required this.colors,
    required this.padding,
    required this.height,
    required this.kMaxSize,
    required this.kIconSize,
    this.buttonLabel,
    this.onPressed,
  });

  final Iterable<Snap> snaps;
  final String slogan;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double padding;
  final double height;
  final double kMaxSize;
  final double kIconSize;

  static const _kForegroundColor = Colors.white;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleTextStyle =
        kIconSize > 40 ? textTheme.headlineSmall! : textTheme.titleMedium!;
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
        ),
      ),
      height: height,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slogan,
                    style: titleTextStyle.copyWith(color: _kForegroundColor),
                  ),
                  if (buttonLabel != null) ...[
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kForegroundColor,
                        side: const BorderSide(color: _kForegroundColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(buttonLabel!),
                    ),
                  ],
                ],
              ),
            ),
            // TODO: add smooth transition
            if (ResponsiveLayout.of(context).type != ResponsiveLayoutType.small)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: snaps
                    .map((snap) => _BannerIcon(
                        snap: snap, kMaxSize: kMaxSize, kIconSize: kIconSize))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _BannerIcon extends StatefulWidget {
  const _BannerIcon({
    required this.snap,
    required this.kMaxSize,
    required this.kIconSize,
  });

  final Snap snap;
  final double kMaxSize;
  final double kIconSize;

  @override
  State<_BannerIcon> createState() => _BannerIconState();
}

class _BannerIconState extends State<_BannerIcon> {
  static const _kHoverDelay = Duration(milliseconds: 100);
  static const _kScaleLarge = 1.5;

  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: Duration.zero,
      showDuration: Duration.zero,
      verticalOffset: widget.kMaxSize / 2,
      message: widget.snap.titleOrName,
      child: InkWell(
        onTap: () => StoreNavigator.pushSnap(context, name: widget.snap.name),
        onHover: (hover) {
          setState(() => scale = hover ? _kScaleLarge : 1.0);
        },
        child: SizedBox(
          height: widget.kMaxSize,
          width: widget.kMaxSize,
          child: Center(
            child: TweenAnimationBuilder(
              curve: Curves.easeIn,
              tween: Tween<double>(begin: 1.0, end: scale),
              duration: _kHoverDelay,
              builder: (context, scale, child) => Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      color: Colors.black.withAlpha(0x19),
                    )
                  ],
                ),
                child: AppIcon(
                  iconUrl: widget.snap.iconUrl,
                  size: widget.kIconSize * scale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// This banner is meant for external tools, which don't adhere to the snap class
// Tools don't have a snap page or a category, but have an url to their website
class ToolsBanner extends ConsumerWidget {
  const ToolsBanner({
    required this.summary,
    required this.buttonText,
    required this.bannerApps,
    super.key,
  });

  final String summary;
  final String buttonText;
  final List<Tool> bannerApps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 29, 27, 112),
            Color.fromARGB(255, 49, 1, 82),
          ],
        ),
      ),
      height: 185,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary, //TODO: l10n
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      StoreNavigator.pushExternalTools(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(buttonText), //TODO: l10n
                  ),
                ],
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: bannerApps
                    .map((tool) => _ExternalToolIcon(tool: tool))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExternalToolIcon extends ConsumerWidget {
  const _ExternalToolIcon({
    required this.tool,
  });

  final Tool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      waitDuration: Duration.zero,
      showDuration: Duration.zero,
      verticalOffset: 88 / 2,
      message: tool.name,
      child: InkWell(
        child: SizedBox(
          height: 88,
          width: 88,
          child: Center(
            child: TweenAnimationBuilder(
              curve: Curves.easeIn,
              tween: Tween<double>(begin: 1.0, end: 1.5),
              duration: const Duration(milliseconds: 100),
              builder: (context, scale, child) => Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      color: Colors.black.withAlpha(0x19),
                    )
                  ],
                ),
                child: AppIcon(
                  iconUrl: tool.iconUrl,
                  size: 48 * scale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
