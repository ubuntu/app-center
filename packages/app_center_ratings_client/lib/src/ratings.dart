// ignore_for_file: invalid_annotation_target

import 'package:app_center_ratings_client/src/generated/ratings_features_common.pb.dart'
    as pb;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ratings.freezed.dart';

@freezed
class Rating with _$Rating {
  @JsonSerializable(explicitToJson: true)
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
      snapId: snapId,
      totalVotes: totalVotes.toInt(),
      ratingsBand: ratingsBand.fromDTO(),
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
