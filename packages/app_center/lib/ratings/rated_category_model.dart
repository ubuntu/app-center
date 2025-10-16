import 'package:app_center/ratings/ratings_service.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'rated_category_model.g.dart';

@immutable
class CategoryList {
  const CategoryList(this.list);

  final List<SnapCategoryEnum> list;

  @override
  int get hashCode => Object.hashAll(list);

  @override
  bool operator ==(Object other) {
    return other is CategoryList && list.equals(other.list);
  }
}

@riverpod
class RatedCategoryModel extends _$RatedCategoryModel {
  late final _ratings = getService<RatingsService>();
  late final _snapd = getService<SnapdService>();

  @override
  Future<List<Snap>> build(
    CategoryList categories,
    int numberOfSnaps,
  ) async {
    final snaps = <Snap>[];

    for (final category in categories.list) {
      final chart = await _ratings.getChart(category);
      for (var i = 0; snaps.length < numberOfSnaps && i < chart.length; i++) {
        final snap =
            (await _snapd.find(name: chart[i].rating.snapName)).singleOrNull;
        if (snap != null && snap.screenshotUrls.isNotEmpty) {
          snaps.add(snap);
        }
      }
    }

    return snaps;
  }
}
