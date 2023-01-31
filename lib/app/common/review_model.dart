import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/constants.dart';

// TODO: adapt to Rating backend when ready
class ReviewModel extends SafeChangeNotifier {
// Static data from backend;
  final double? averageRating = 5.0;

  Future<void> load(String appId, String version) async {
    _userReviews = [
      for (var i = 0; i < 20; i++)
        AppReview(
          rating: 3.4,
          review: kFakeReviewText,
          dateTime: DateTime.now(),
          username: null,
          positiveVote: 10,
          negativeVote: 2,
        ),
    ];
    notifyListeners();
  }

  List<AppReview>? _userReviews;
  List<AppReview>? get userReviews => _userReviews;

  // Setter getter to hold state before sending
  double? _rating;
  double? get rating => _rating;
  set rating(double? value) {
    if (value == null || value == _rating) return;
    _rating = value;
    notifyListeners();
  }

  String? _review;
  String? get review => _review;
  set review(String? value) {
    if (value == null || value == _review) return;
    _review = value;
    notifyListeners();
  }

  String? _title;
  String? get title => _title;
  set title(String? value) {
    if (value == null || value == _title) return;
    _title = value;
    notifyListeners();
  }

  String? _user;
  String? get user => _user;
  set user(String? value) {
    if (value == null || value == _user) return;
    _user = value;
    notifyListeners();
  }

  Future<void> submit(String appId, String version) async {}

  Future<void> vote(AppReview review, bool positive) async {}

  Future<void> flag(AppReview review) async {}
}
