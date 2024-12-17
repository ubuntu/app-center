import 'package:app_center/ratings/ratings_service.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'rated_category_model.g.dart';

@riverpod
class RatedCategoryModel extends _$RatedCategoryModel {
  late final _ratings = getService<RatingsService>();
  late final _snapd = getService<SnapdService>();

  @override
  Future<List<Snap>> build(
    List<SnapCategoryEnum> categories,
    int numberOfSnaps,
  ) async {
    final snaps = <Snap>[];

    for (final category in categories) {
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
