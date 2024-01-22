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
import 'package:yaru_icons/yaru_icons.dart';

const kNumberOfBannerSnaps = 3;

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.compass_filled : YaruIcons.compass;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).explorePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverList.list(children: const [
          SizedBox(height: kPagePadding),
          CategoryBanner(category: SnapCategoryEnum.ubuntuDesktop),
          SizedBox(height: kPagePadding),
        ]),
        const CategorySnapList(
          category: SnapCategoryEnum.ubuntuDesktop,
          hideBannerSnaps: true,
        ),
        SliverList.list(children: const [
          SizedBox(height: 56),
          CategoryBanner(category: SnapCategoryEnum.featured),
          SizedBox(height: kPagePadding),
        ]),
        const CategorySnapList(
          category: SnapCategoryEnum.featured,
          hideBannerSnaps: true,
        ),
        SliverList.list(children: [
          const SizedBox(height: 56),
          _Title(text: SnapCategoryEnum.games.slogan(l10n)),
          const SizedBox(height: kPagePadding),
        ]),
        const CategorySnapList(
          category: SnapCategoryEnum.games,
          numberOfSnaps: 4,
          showScreenshots: true,
          onlyFeatured: true,
        ),
        SliverList.list(children: [
          const SizedBox(height: 56),
          _Title(text: l10n.explorePageCategoriesLabel),
          const SizedBox(height: kPagePadding),
        ]),
        const _CategoryList(),
        SliverList.list(children: const [
          SizedBox(height: 56),
          CategoryBanner(category: SnapCategoryEnum.development),
          SizedBox(height: kPagePadding),
        ]),
        const CategorySnapList(
          category: SnapCategoryEnum.development,
          hideBannerSnaps: true,
        ),
        SliverList.list(children: const [
          SizedBox(height: 56),
          CategoryBanner(category: SnapCategoryEnum.productivity),
          SizedBox(height: kPagePadding),
        ]),
        const CategorySnapList(
          category: SnapCategoryEnum.productivity,
          hideBannerSnaps: true,
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: kPagePadding),
        ),
      ],
    );
  }
}

// TODO: promote private widgets to customizable stand-alone widgets

class _Title extends StatelessWidget {
  const _Title({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class CategoryBanner extends ConsumerWidget {
  const CategoryBanner({
    required this.category,
    this.padding = 48,
    this.height = 240,
    this.kMaxSize = 88.0,
    this.kIconSize = 48.0,
    this.fontSize = 24,
    super.key,
  });

  final SnapCategoryEnum category;
  final double padding;
  final double height;
  final double kMaxSize;
  final double kIconSize;
  final double fontSize;

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
      fontSize: fontSize,
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
    required this.fontSize,
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
  final double fontSize;

  static const _kForegroundColor = Colors.white;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleTextStyle = kIconSize > 40 ? textTheme.headlineSmall! : textTheme.titleMedium!;
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

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  @override
  Widget build(BuildContext context) {
    return SliverGrid.count(
      mainAxisSpacing: kCardSpacing,
      crossAxisSpacing: kCardSpacing,
      childAspectRatio: 6,
      crossAxisCount: ResponsiveLayout.of(context).snapInfoColumnCount,
      children: SnapCategoryEnum.values
          .whereNot((category) => category.hidden)
          .map((category) => InkWell(
                onTap: () => StoreNavigator.pushSearch(context,
                    category: category.categoryName),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(category.icon(true)),
                    const SizedBox(width: 8),
                    Text(category.localize(AppLocalizations.of(context)))
                  ],
                ),
              ))
          .toList(),
    );
  }
}
