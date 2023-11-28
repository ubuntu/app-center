import 'package:app_center_ratings_client/ratings_client.dart';
import 'package:flutter/material.dart';

import '../../l10n.dart';

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
    return switch (this) {
      RatingsBand.veryGood => const Color(0xFF0E8420),
      RatingsBand.good => const Color(0xFF0E8420),
      RatingsBand.neutral => const Color(0xFFC75A00),
      RatingsBand.poor => const Color(0xFFC7162B),
      RatingsBand.veryPoor => const Color(0xFFC7162B),
      RatingsBand.insufficientVotes => Colors.grey,
    };
  }
}
