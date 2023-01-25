import 'package:odrs/odrs.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/services/odrs_service.dart';

class ReviewModel extends SafeChangeNotifier {
  ReviewModel(this._odrs);

  final OdrsService _odrs;

  Future<void> load(String appId, [String? version]) async {
    await for (final reviews in _odrs.getReviews(appId, version: version)) {
      _userReviews = reviews.map((r) => r.toAppReview()).toList();
      notifyListeners();
    }
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

extension on OdrsReview {
  AppReview toAppReview() {
    return AppReview(
      id: reviewId,
      rating: rating / 100.0 * 5,
      review: description,
      title: summary,
      dateTime: dateCreated,
      username: userDisplay,
      positiveVote: karmaUp,
      negativeVote: karmaDown,
    );
  }
}
