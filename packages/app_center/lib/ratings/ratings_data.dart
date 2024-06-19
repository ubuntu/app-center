import 'package:app_center/ratings/ratings.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ratings_data.freezed.dart';

@freezed
class RatingsData with _$RatingsData {
  const factory RatingsData({
    required String snapId,
    required String snapRevision,
    required Rating? rating,
    required VoteStatus? voteStatus,
  }) = _RatingsData;
}
