import 'package:app_center/ratings/ratings.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ratings_data.freezed.dart';
part 'ratings_data.g.dart';

@freezed
class RatingsData with _$RatingsData {
  const factory RatingsData({
    required String snapId,
    required int snapRevision,
    required Rating? rating,
    required VoteStatus? voteStatus,
    required String snapName,
  }) = _RatingsData;

  factory RatingsData.fromJson(Map<String, dynamic> json) =>
      _$RatingsDataFromJson(json);
}
