import 'package:app_center/providers/file_system_provider.dart';
import 'package:app_center/ratings/ratings_data.dart';
import 'package:app_center/ratings/ratings_service.dart';
import 'package:app_center/snapd/cache_file.dart';
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

    final cacheFile = _getCacheFile(snapId);

    RatingsData? cachedRatingsData;
    if (cacheFile.existsSync() && cacheFile.isValidSync()) {
      cachedRatingsData = await cacheFile.readRatingsData();
    }

    if (cachedRatingsData != null) {
      return cachedRatingsData;
    }

    final results = await Future.wait([
      _ratings.getRating(snapId),
      _ratings.getSnapVotes(snapId),
    ]);

    final rating = results[0] as Rating;
    final votes = results[1] as List<Vote>;

    final ratingsData = RatingsData(
      snapId: snapId,
      snapRevision: snap.revision,
      rating: rating,
      voteStatus: _getUserVote(snap.revision, votes),
    );

    cacheFile.writeRatingsDataSync(ratingsData);
    return ratingsData;
  }

  Future<void> castVote(VoteStatus voteStatus) async {
    assert(state.hasValue, 'Cannot cast vote before loading is finished');
    final ratingsData = state.value!;
    final voteUp = voteStatus == VoteStatus.up ? true : false;

    if (voteStatus != ratingsData.voteStatus) {
      final vote = Vote(
        snapId: ratingsData.snapId,
        snapRevision: ratingsData.snapRevision,
        voteUp: voteUp,
        dateTime: clock.now(),
      );
      await _ratings.vote(vote);
      state = AsyncData(ratingsData.copyWith(voteStatus: voteStatus));
      await _getCacheFile(ratingsData.snapId).deleteIfExists();
      ref.invalidateSelf();
    }
  }

  VoteStatus? _getUserVote(int snapRevision, List<Vote?> votes) {
    for (final vote in votes) {
      if (vote != null && vote.snapRevision == snapRevision) {
        return vote.voteUp ? VoteStatus.up : VoteStatus.down;
      }
    }
    return null;
  }

  CacheFile _getCacheFile(String snapId) {
    return CacheFile.fromFileName(
      'ratings-$snapId',
      fileSystem: ref.read(fileSystemProvider),
      expiry: const Duration(days: 1),
    );
  }
}

enum VoteStatus {
  up,
  down;
}
