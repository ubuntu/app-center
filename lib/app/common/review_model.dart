import 'package:glib/glib.dart';
import 'package:odrs/odrs.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/services/odrs_service.dart';

enum ReviewResult { ok, abuse, taboo, error }

class ReviewModel extends SafeChangeNotifier {
  ReviewModel(this._odrs);

  final OdrsService _odrs;
  String? _appId;
  String? _version;

  Future<void> load(String appId, String version) async {
    _appId = appId;
    _version = version;

    await for (final reviews in _odrs.getReviews(appId, version: version)) {
      _ownReview = null;
      _userReviews = reviews
          .map((r) {
            final review = _odrs.toAppReview(r);
            if (review.own == true) {
              _ownReview = review;
            }
            return review;
          })
          .where((r) => r.own != true)
          .toList();
      notifyListeners();
    }
  }

  AppReview? _ownReview;
  AppReview? get ownReview => _ownReview;

  List<AppReview>? _userReviews;
  List<AppReview>? get userReviews => _userReviews;

  Future<ReviewResult> submit(AppReview review) async {
    final error = await _odrs.submitReview(
      appId: _appId!,
      rating: review.rating!.toOdrsRating(),
      version: _version!,
      userDisplay: glib.getRealName(),
      summary: review.title!,
      description: review.review!,
    );
    if (error == null) {
      await load(_appId!, _version!);
      return ReviewResult.ok;
    }
    return switch (error) {
      OdrsError.accountDisabled => ReviewResult.abuse,
      OdrsError.tabooWord => ReviewResult.taboo,
      _ => ReviewResult.error,
    };
  }

  Future<void> vote(AppReview review, bool positive) async {}

  Future<void> flag(AppReview review) async {}
}

extension on OdrsService {
  AppReview toAppReview(OdrsReview review) {
    return AppReview(
      id: review.reviewId,
      rating: review.rating.toAppRating(),
      review: review.description,
      title: review.summary,
      dateTime: review.dateCreated,
      username: review.userDisplay,
      positiveVote: review.karmaUp,
      negativeVote: review.karmaDown,
      own: isOwnReview(review),
    );
  }
}

extension on int {
  double toAppRating() => this / 100.0 * 5;
}

extension on double {
  int toOdrsRating() => (this / 5 * 100.0).round();
}
