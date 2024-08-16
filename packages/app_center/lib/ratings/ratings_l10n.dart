import 'package:app_center/l10n.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter/material.dart';
import 'package:yaru/theme.dart';

extension RatingsBandL10n on RatingsBand {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      RatingsBand.veryGood => l10n.snapRatingsBandVeryGood,
      RatingsBand.good => l10n.snapRatingsBandGood,
      RatingsBand.neutral => l10n.snapRatingsBandNeutral,
      RatingsBand.poor => l10n.snapRatingsBandPoor,
      RatingsBand.veryPoor => l10n.snapRatingsBandVeryPoor,
      RatingsBand.insufficientVotes => l10n.snapRatingsBandInsufficientVotes,
    };
  }

  Color getColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return switch (this) {
      RatingsBand.veryGood => colors.success,
      RatingsBand.good => colors.success,
      RatingsBand.neutral => colors.warning,
      RatingsBand.poor => colors.error,
      RatingsBand.veryPoor => colors.error,
      RatingsBand.insufficientVotes => Colors.grey,
    };
  }
}
