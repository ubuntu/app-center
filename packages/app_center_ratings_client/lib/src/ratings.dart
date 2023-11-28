import 'package:freezed_annotation/freezed_annotation.dart';

import 'generated/ratings_features_common.pb.dart' as pb;

@immutable
class Rating {
  final String snapId;
  final int totalVotes;
  final RatingsBand ratingsBand;

  const Rating({
    required this.snapId,
    required this.totalVotes,
    required this.ratingsBand,
  });

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
