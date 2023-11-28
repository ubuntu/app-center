import 'package:app_center/ratings.dart';
import 'package:app_center_ratings_client/ratings_client.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

void main() {
  test('init', () async {
    final mockService = createMockRatingsService(
      rating: const Rating(
        snapId: 'firefox',
        totalVotes: 1337,
        ratingsBand: RatingsBand.veryGood,
      ),
      snapVotes: [
        Vote(
          snapId: 'firefox',
          snapRevision: 42,
          voteUp: true,
          dateTime: DateTime(1970),
        ),
      ],
    );
    final model = RatingsModel(
      ratings: mockService,
      snapId: 'firefox',
      snapRevision: '42',
    );

    await model.init();
    expect(model.state.hasValue, isTrue);
    expect(
      model.snapRating,
      equals(
        const Rating(
          snapId: 'firefox',
          totalVotes: 1337,
          ratingsBand: RatingsBand.veryGood,
        ),
      ),
    );
    expect(model.vote, equals(VoteStatus.up));
  });

  test('cast vote', () async {
    final mockService = createMockRatingsService();
    final model = RatingsModel(
      ratings: mockService,
      snapId: 'firefox',
      snapRevision: '42',
    );

    await model.init();
    await withClock(
      Clock.fixed(DateTime(1984)),
      () => model.castVote(VoteStatus.up),
    );
    verify(
      mockService.vote(
        Vote(
          dateTime: DateTime(1984),
          snapId: 'firefox',
          snapRevision: 42,
          voteUp: true,
        ),
      ),
    ).called(1);
  });
}
