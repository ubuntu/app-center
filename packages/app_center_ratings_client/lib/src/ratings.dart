import 'package:app_center_ratings_client/src/generated/ratings_features_common.pb.dart'
    as pb;
import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class Rating {
  const Rating({
    required this.snapId,
    required this.totalVotes,
    required this.ratingsBand,
  });
  final String snapId;
  final int totalVotes;
  final RatingsBand ratingsBand;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Rating &&
        other.snapId == snapId &&
        other.totalVotes == totalVotes &&
        other.ratingsBand == ratingsBand;
  }

  @override
  int get hashCode =>
      snapId.hashCode ^ totalVotes.hashCode ^ ratingsBand.hashCode;
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
