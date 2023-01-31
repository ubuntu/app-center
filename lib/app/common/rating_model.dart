import 'package:async/async.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/app/common/app_rating.dart';
import 'package:software/services/odrs_service.dart';

const _kCachePeriod = Duration(minutes: 10);

class RatingModel extends SafeChangeNotifier {
  RatingModel(this._odrs);

  final OdrsService _odrs;
  var _ratings = <String, AppRating>{};
  final _cache = AsyncCache(_kCachePeriod);

  AppRating? getRating(String appId) {
    _cache.fetch(() async {
      await for (final ratings in _odrs.getRatings()) {
        _ratings = ratings.map((k, v) => MapEntry(k, v.toAppRating()));
        notifyListeners();
      }
    });
    return _ratings[appId];
  }
}

extension on OdrsRating {
  AppRating toAppRating() => AppRating(average: average, total: total);
}
