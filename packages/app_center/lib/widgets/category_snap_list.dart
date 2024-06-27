import 'package:app_center/explore/explore_page.dart';
import 'package:app_center/ratings/ratings_service.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

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
        .valueOrNull;

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
        ?.map(
          (name) =>
              filteredSnaps?.singleWhereOrNull((snap) => snap.name == name),
        )
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

class RatedCategorySnapList extends ConsumerStatefulWidget {
  const RatedCategorySnapList(
      {required this.categories, this.numberOfSnaps = 6, super.key});

  final Set<SnapCategoryEnum> categories;
  final int numberOfSnaps;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RatedCategorySnapList();
}

class _RatedCategorySnapList extends ConsumerState<RatedCategorySnapList> {
  _RatedCategorySnapList();

  List<Snap> snaps = [];

  Future<void> fetchItems() async {
    final ratings = getService<RatingsService>();
    final snapd = getService<SnapdService>();

    for (final category in widget.categories) {
      final chart = await ratings.getChart(category);
      var i = 0;
      while (snaps.length < widget.numberOfSnaps && i < chart.length) {
        final snap = await snapd.findById(chart[i].rating.snapId);
        if (snap != null && snap.screenshotUrls.isNotEmpty) {
          setState(() {
            snaps.add(snap);
          });
        }
        i++;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return AppCardGrid.fromRatedSnaps(
      snaps: snaps,
      onTap: (snap) => StoreNavigator.pushSnap(
        context,
        name: snap.name,
      ),
    );
  }
}
