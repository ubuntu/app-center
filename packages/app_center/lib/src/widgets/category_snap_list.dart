import 'package:app_center/snapd.dart';
import 'package:app_center/src/explore/explore_page.dart';
import 'package:app_center/store.dart';
import 'package:app_center/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategorySnapList extends ConsumerWidget {
  const CategorySnapList({
    required this.category,
    this.numberOfSnaps = 6,
    this.showScreenshots = false,
    this.onlyFeatured = false,
    this.hideBannerSnaps = false,
    super.key,
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
        : AppCardGrid.fromSnaps(
            snaps: snaps,
            onTap: (snap) => StoreNavigator.pushSnap(context, name: snap.name),
          );
  }
}
