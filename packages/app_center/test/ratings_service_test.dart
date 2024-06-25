import 'package:app_center/ratings/ratings_service.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

void main() {
  test('get rating', () async {
    final mockClient = createMockRatingsClient(
      token: 'jwt',
      rating: const Rating(
        snapId: 'firefox',
        totalVotes: 1337,
        ratingsBand: RatingsBand.veryGood,
      ),
    );
    final service = RatingsService(mockClient, id: 'myId');

    final rating = await service.getRating('firefox');
    verify(mockClient.authenticate('myId')).called(1);
    expect(
      rating,
      equals(
        const Rating(
          snapId: 'firefox',
          totalVotes: 1337,
          ratingsBand: RatingsBand.veryGood,
        ),
      ),
    );
  });

  test('vote', () async {
    final mockClient = createMockRatingsClient(token: 'jwt');
    final service = RatingsService(mockClient, id: 'myId');

    await service.vote(
      Vote(
        snapId: 'thunderbird',
        snapRevision: 42,
        voteUp: true,
        dateTime: DateTime(1970),
      ),
    );
    verify(mockClient.authenticate('myId')).called(1);
    verify(mockClient.vote('thunderbird', 42, true, 'jwt')).called(1);
  });

  test('delete', () async {
    final mockClient = createMockRatingsClient(token: 'jwt');
    final service = RatingsService(mockClient, id: 'myId');

    await service.delete();
    verify(mockClient.authenticate('myId')).called(1);
    verify(mockClient.delete('jwt')).called(1);
  });

  test('list my votes', () async {
    final mockClient = createMockRatingsClient(
      token: 'jwt',
      myVotes: [
        Vote(
          snapId: 'testsnap',
          snapRevision: 1,
          voteUp: false,
          dateTime: DateTime(1984),
        ),
      ],
    );
    final service = RatingsService(mockClient, id: 'myId');

    final votes = await service.listMyVotes('testsnap');
    verify(mockClient.authenticate('myId')).called(1);
    expect(
      votes,
      equals(
        [
          Vote(
            snapId: 'testsnap',
            snapRevision: 1,
            voteUp: false,
            dateTime: DateTime(1984),
          ),
        ],
      ),
    );
  });

  test('snap votes', () async {
    final mockClient = createMockRatingsClient(
      token: 'jwt',
      snapVotes: [
        Vote(
          snapId: 'testsnap2',
          snapRevision: 2,
          voteUp: true,
          dateTime: DateTime(1999),
        ),
      ],
    );
    final service = RatingsService(mockClient, id: 'myId');

    final votes = await service.getSnapVotes('testsnap2');
    verify(mockClient.authenticate('myId')).called(1);
    expect(
      votes,
      equals(
        [
          Vote(
            snapId: 'testsnap2',
            snapRevision: 2,
            voteUp: true,
            dateTime: DateTime(1999),
          ),
        ],
      ),
    );
  });
}
