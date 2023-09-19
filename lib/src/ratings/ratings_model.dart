import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'exports.dart';

import 'ratings_service.dart';

final ratingsModelProvider =
    ChangeNotifierProvider.family.autoDispose<RatingsModel, Snap>(
  (ref, snap) => RatingsModel(
    ratings: getService<RatingsService>(),
    snapId: snap.id,
    snapRevision: snap.revision,
  )..init(),
);

class RatingsModel extends ChangeNotifier {
  RatingsModel({
    required this.ratings,
    required this.snapId,
    required this.snapRevision,
  }) : _state = const AsyncValue.loading();
  final RatingsService ratings;
  final String snapId;
  final String snapRevision;

  Rating? snapRating;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  VoteStatus? get vote => _vote;
  VoteStatus? _vote;

  Future<void> init() async {
    _state = await AsyncValue.guard(() async {
      final results = await Future.wait([
        ratings.getRating(snapId),
        ratings.getSnapVotes(snapId),
      ]);

      final rating = results[0] as Rating;
      final votes = results[1] as List<Vote>;

      _setSnapRating(rating);
      _setUserVote(votes);
    });
    notifyListeners();
  }

  void _setSnapRating(Rating? rating) {
    snapRating = rating;
  }

  void _setUserVote(List<Vote?> votes) {
    for (final vote in votes) {
      if (vote != null && vote.snapRevision == int.parse(snapRevision)) {
        _vote = vote.voteUp ? VoteStatus.up : VoteStatus.down;
        notifyListeners();
        return;
      }
    }
  }

  Future<void> castVote(VoteStatus castVote) async {
    bool voteUp = castVote == VoteStatus.up ? true : false;

    if (castVote != _vote) {
      final vote = Vote(
        snapId: snapId,
        snapRevision: int.parse(snapRevision),
        voteUp: voteUp, // using voteUp directly here
        dateTime: DateTime.now(),
      );
      await ratings.vote(vote);
      _vote = castVote;
    }

    notifyListeners();
  }
}

enum VoteStatus {
  up,
  down,
}
