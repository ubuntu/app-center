import 'package:app_center/explore.dart';
import 'package:app_center/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/store/store_pages.dart';
import 'package:app_center/src/widgets/app_icon.dart';
import 'package:app_center/store.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';

class GamesPage extends ConsumerWidget {
  const GamesPage({super.key});

  static IconData icon(bool selected) => SnapCategoryEnum.games.icon(selected);
  static String label(BuildContext context) =>
      AppLocalizations.of(context).gamesPageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverList.list(children: [
          const SizedBox(height: 56),
          _Title(text: SnapCategoryEnum.games.localize(l10n)),
          const SizedBox(height: kPagePadding),
        ]),
        SliverList.list(children: const [
          SizedBox(height: 56),
          GamesPageFeatured(),
          SizedBox(height: kPagePadding),
        ]),
        SliverList.list(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 306 - 160,
                  child: _CategoryBanner(category: SnapCategoryEnum.gameDev)
                ),
                Container(width: 12),
                const Expanded(
                  flex: 306 - 160,
                  child: _CategoryBanner(category: SnapCategoryEnum.gameEmulators)
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  flex: 306 - 160,
                  child: _CategoryBanner(category: SnapCategoryEnum.gnomeGames)
                ),
                Container(width: 12),
                const Expanded(
                  flex: 306 - 160,
                  child: _CategoryBanner(category: SnapCategoryEnum.kdeGames)
                )
              ],
            )
          ],
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.headlineSmall);
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
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.snaps,
    required this.slogan,
    required this.colors,
    this.buttonLabel,
    this.onPressed,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: colors,
        ),
      ),
      height: 150,
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
                        .titleMedium!
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
  static const _kMaxSize = 60.0;
  static const _kHoverDelay = Duration(milliseconds: 100);
  static const _kIconSize = 24.0;
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
