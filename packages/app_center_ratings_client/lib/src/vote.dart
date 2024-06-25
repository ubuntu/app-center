import 'package:app_center_ratings_client/src/generated/ratings_features_user.pb.dart'
    as pb;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote.freezed.dart';

@freezed
class Vote with _$Vote {
  const factory Vote({
    required String snapId,
    required int snapRevision,
    required bool voteUp,
    required DateTime dateTime,
  }) = _Vote;
}

extension VoteFromDTO on pb.Vote {
  Vote fromDTO() {
    return Vote(
      snapId: snapId,
      snapRevision: snapRevision,
      voteUp: voteUp,
      dateTime: timestamp.toDateTime(),
    );
  }
}
