import 'package:software/l10n/l10n.dart';

enum ReviewSortBy {
  mostRecent,
  mostUseful,
  highestRating,
  lowestRating;

  String localize(AppLocalizations l10n) {
    return switch (this) {
      mostRecent => l10n.appReviewsMostRecent,
      mostUseful => l10n.appReviewsMostUseful,
      highestRating => l10n.appReviewsHighestRating,
      lowestRating => l10n.appReviewsLowestRating,
    };
  }
}
