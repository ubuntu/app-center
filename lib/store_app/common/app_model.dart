import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'app_data.dart';
import 'constants.dart';

// TODO: adapt to Rating backend when ready
class AppModel extends SafeChangeNotifier {
  // Static data from backend;
  final double? averageRating = 5.0;

  final List<AppReview>? userReviews = [
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

  // Setter getter to hold state before sending
  double? _reviewRating;
  double? get reviewRating => _reviewRating;
  set reviewRating(double? value) {
    if (value == null || value == _reviewRating) return;
    _reviewRating = value;
    notifyListeners();
  }

  String? _review;
  String? get review => _review;
  set review(String? value) {
    if (value == null || value == _review) return;
    _review = value;
    notifyListeners();
  }

  String? _reviewTitle;
  String? get reviewTitle => _reviewTitle;
  set reviewTitle(String? value) {
    if (value == null || value == _reviewTitle) return;
    _reviewTitle = value;
    notifyListeners();
  }

  String? _reviewUser;
  String? get reviewUser => _reviewUser;
  set reviewUser(String? value) {
    if (value == null || value == _reviewUser) return;
    _reviewUser = value;
    notifyListeners();
  }

  void sendReview() {
    // ignore: unused_local_variable
    final newReview = AppReview(
      rating: averageRating,
      title: reviewTitle,
      dateTime: DateTime.now(),
      username: reviewUser,
    );
  }

  void voteReview(AppReview appReview, bool negative) {}
  void flagReview(AppReview appReview) {}
}
