import 'package:freezed_annotation/freezed_annotation.dart';

import 'generated/ratings_features_user.pb.dart' as pb;

part 'user.freezed.dart';

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
      snapId: this.snapId,
      snapRevision: this.snapRevision,
      voteUp: this.voteUp,
      dateTime: this.timestamp.toDateTime(),
    );
  }
}
