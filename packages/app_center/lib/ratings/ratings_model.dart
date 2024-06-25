import 'package:app_center/ratings/ratings_data.dart';
import 'package:app_center/ratings/ratings_service.dart';
import 'package:app_center/snapd/snap_model.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'ratings_model.g.dart';

@riverpod
class RatingsModel extends _$RatingsModel {
  late final _ratings = getService<RatingsService>();

  @override
  Future<RatingsData> build(String snapName) async {
    final snap = (await ref.watch(snapModelProvider(snapName).future)).snap;
    final snapId = snap.id;

    final results = await Future.wait([
      _ratings.getRating(snapId),
      _ratings.getSnapVotes(snapId),
    ]);

    final rating = results[0] as Rating;
    final votes = results[1] as List<Vote>;

    return RatingsData(
      snapId: snapId,
      snapRevision: snap.revision,
      rating: rating,
      voteStatus: _getUserVote(snap.revision, votes),
    );
  }

  Future<void> castVote(VoteStatus voteStatus) async {
    assert(state.hasValue, 'Cannot cast vote before loading is finished');
    final ratingsData = state.value!;
    final voteUp = voteStatus == VoteStatus.up ? true : false;

    if (voteStatus != ratingsData.voteStatus) {
      final vote = Vote(
        snapId: ratingsData.snapId,
        snapRevision: int.parse(ratingsData.snapRevision),
        voteUp: voteUp,
        dateTime: clock.now(),
      );
      await _ratings.vote(vote);
      state = AsyncData(ratingsData.copyWith(voteStatus: voteStatus));
    }
  }

  VoteStatus? _getUserVote(String snapRevision, List<Vote?> votes) {
    for (final vote in votes) {
      if (vote != null && vote.snapRevision == int.parse(snapRevision)) {
        return vote.voteUp ? VoteStatus.up : VoteStatus.down;
      }
    }
    return null;
  }
}

enum VoteStatus {
  up,
  down;
}
