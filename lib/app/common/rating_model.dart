import 'dart:math';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/app/common/app_rating.dart';

class RatingModel extends SafeChangeNotifier {
  RatingModel();

  final Map<String, AppRating?> _ratings = {};

  AppRating? getRating(String appId) {
    if (!_ratings.containsKey(appId)) {
      _ratings[appId] = null;
      Future.delayed(fakeDelay()).then((value) {
        _ratings[appId] = AppRating(
          average: fakeRating(),
          total: fakeTotalRatings(),
        );
        notifyListeners();
      });
    }
    return _ratings[appId];
  }

  double fakeRating() => 4.5;
  int fakeTotalRatings() => Random().nextInt(3000);
  Duration fakeDelay() => Duration(milliseconds: Random().nextInt(100));
}
