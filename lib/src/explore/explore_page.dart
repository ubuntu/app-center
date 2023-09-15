import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '/l10n.dart';
import '/layout.dart';
import '/snapd.dart';
import '/store.dart';
import '/widgets.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPagePadding),
      child: ResponsiveLayoutScrollView(
        slivers: [
          SliverList.list(children: const [
            _CategoryBanner(category: SnapCategoryEnum.ubuntuDesktop),
            SizedBox(height: 24),
          ]),
          const _CategorySnapList(
            category: SnapCategoryEnum.ubuntuDesktop,
            hideBannerSnaps: true,
          ),
          SliverList.list(children: const [
            SizedBox(height: 56),
            _CategoryBanner(category: SnapCategoryEnum.featured),
            SizedBox(height: 24),
          ]),
          const _CategorySnapList(
            category: SnapCategoryEnum.featured,
            hideBannerSnaps: true,
          ),
          SliverList.list(children: [
            const SizedBox(height: 56),
            _Title(text: SnapCategoryEnum.games.slogan(l10n)),
            const SizedBox(height: 24),
          ]),
          const _CategorySnapList(
            category: SnapCategoryEnum.games,
            numberOfSnaps: 4,
            showScreenshots: true,
            onlyFeatured: true,
          ),
          SliverList.list(children: [
            const SizedBox(height: 56),
            _Title(text: l10n.explorePageCategoriesLabel),
            const SizedBox(height: 24),
          ]),
          const _CategoryList(),
          SliverList.list(children: const [
            SizedBox(height: 56),
            _CategoryBanner(category: SnapCategoryEnum.development),
            SizedBox(height: 24),
          ]),
          const _CategorySnapList(
            category: SnapCategoryEnum.development,
            hideBannerSnaps: true,
          ),
          SliverList.list(children: const [
            SizedBox(height: 56),
            _CategoryBanner(category: SnapCategoryEnum.productivity),
            SizedBox(height: 24),
          ]),
          const _CategorySnapList(
            category: SnapCategoryEnum.productivity,
            hideBannerSnaps: true,
          ),
        ],
      ),
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

class _CategorySnapList extends ConsumerWidget {
  const _CategorySnapList({
    required this.category,
    this.numberOfSnaps = 6,
    this.showScreenshots = false,
    this.onlyFeatured = false,
    this.hideBannerSnaps = false,
  });

  final SnapCategoryEnum category;
  final int numberOfSnaps;
  final bool showScreenshots;
  final bool onlyFeatured;
  final bool hideBannerSnaps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // get snaps from `category`
    final categorySnaps = ref
        .watch(snapSearchProvider(SnapSearchParameters(category: category)))
        .whenOrNull(data: (data) => data);

    final bannerSnaps =
        category.featuredSnapNames?.take(kNumberOfBannerSnaps) ??
            categorySnaps?.take(kNumberOfBannerSnaps).map((snap) => snap.name);

    // .. without the banner snaps, if we don't want them
    final filteredSnaps = categorySnaps?.where(
      (snap) =>
          hideBannerSnaps ? !(bannerSnaps ?? []).contains(snap.name) : true,
    );

    // pick hand-selected featured snaps
    final featuredSnaps = category.featuredSnapNames
        ?.map((name) =>
            filteredSnaps?.singleWhereOrNull((snap) => snap.name == name))
        .whereNotNull();

    final snaps = (onlyFeatured ? featuredSnaps : filteredSnaps)
            ?.take(numberOfSnaps)
            .toList() ??
        [];
    return showScreenshots
        ? SnapImageCardGrid(
            snaps: snaps,
            onTap: (snap) => StoreNavigator.pushSnap(context, name: snap.name),
          )
        : SnapCardGrid(
            snaps: snaps,
            onTap: (snap) => StoreNavigator.pushSnap(context, name: snap.name),
          );
  }
}

class _CategoryBanner extends ConsumerWidget {
  const _CategoryBanner({required this.category});

  final SnapCategoryEnum category;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snaps = ref
        .watch(snapSearchProvider(SnapSearchParameters(category: category)))
        .whenOrNull(data: (data) => data);
    final featuredSnaps = category.featuredSnapNames != null
        ? category.featuredSnapNames!
            .map((name) =>
                snaps?.singleWhereOrNull(((snap) => snap.name == name)))
            .whereNotNull()
        : snaps;
    final l10n = AppLocalizations.of(context);
    return _Banner(
      snaps: featuredSnaps?.take(kNumberOfBannerSnaps).toList() ?? [],
      slogan: category.slogan(l10n),
      buttonLabel: category.buttonLabel(l10n),
      onPressed: () =>
          StoreNavigator.pushSearch(context, category: category.categoryName),
      colors: category.bannerColors,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.snaps,
    required this.slogan,
    this.buttonLabel,
    this.onPressed,
    required this.colors,
  });

  final Iterable<Snap> snaps;
  final String slogan;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  static const _kForegroundColor = Colors.white;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
        ),
      ),
      height: 240,
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: _kForegroundColor),
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
                mainAxisSize: MainAxisSize.min,
                children: snaps.map((snap) => _BannerIcon(snap: snap)).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _BannerIcon extends StatefulWidget {
  const _BannerIcon({required this.snap});

  final Snap snap;

  @override
  State<_BannerIcon> createState() => _BannerIconState();
}

class _BannerIconState extends State<_BannerIcon> {
  static const _kMaxSize = 88.0;
  static const _kHoverDelay = Duration(milliseconds: 100);
  static const _kIconSize = 48.0;
  static const _kScaleLarge = 1.5;

  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: Duration.zero,
      showDuration: Duration.zero,
      verticalOffset: _kMaxSize / 2,
      message: widget.snap.titleOrName,
      child: InkWell(
        onTap: () => StoreNavigator.pushSnap(context, name: widget.snap.name),
        onHover: (hover) {
          setState(() => scale = hover ? _kScaleLarge : 1.0);
        },
        child: SizedBox(
          height: _kMaxSize,
          width: _kMaxSize,
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
                  size: _kIconSize * scale,
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
                    Icon(category.getIcon(false)),
                    const SizedBox(width: 8),
                    Text(category.localize(AppLocalizations.of(context)))
                  ],
                ),
              ))
          .toList(),
    );
  }
}
