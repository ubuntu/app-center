import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/store.dart';
import 'package:app_center/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
