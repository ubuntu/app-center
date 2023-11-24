import 'package:freezed_annotation/freezed_annotation.dart';

import 'generated/ratings_features_app.pb.dart' as pb;

part 'app.freezed.dart';

@freezed
class Rating with _$Rating {
  const factory Rating({
    required String snapId,
    required int totalVotes,
    required RatingsBand ratingsBand,
  }) = _Rating;
}

enum RatingsBand {
  veryGood,
  good,
  neutral,
  poor,
  veryPoor,
  insufficientVotes,
}

extension RatingFromDTO on pb.Rating {
  Rating fromDTO() {
    return Rating(
      snapId: this.snapId,
      totalVotes: this.totalVotes.toInt(),
      ratingsBand: this.ratingsBand.fromDTO(),
    );
  }
}

extension RatingsBandFromDTO on pb.RatingsBand {
  RatingsBand fromDTO() {
    return switch (this) {
      pb.RatingsBand.VERY_GOOD => RatingsBand.veryGood,
      pb.RatingsBand.GOOD => RatingsBand.good,
      pb.RatingsBand.NEUTRAL => RatingsBand.neutral,
      pb.RatingsBand.POOR => RatingsBand.poor,
      pb.RatingsBand.VERY_POOR => RatingsBand.veryPoor,
      _ => RatingsBand.insufficientVotes,
    };
  }
}
