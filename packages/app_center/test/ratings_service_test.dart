import 'package:app_center/ratings/ratings_service.dart';
import 'package:app_center/snapd/snap_category_enum.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

void main() {
  test('get rating', () async {
    final mockClient = createMockRatingsClient(
      token: 'jwt',
      rating: const Rating(
        snapId: '1234',
        totalVotes: 1337,
        ratingsBand: RatingsBand.veryGood,
        snapName: 'firefox',
      ),
    );
    final service = RatingsService(mockClient, id: 'myId');

    final rating = await service.getRating('firefox', '1234');
    verify(mockClient.authenticate('myId')).called(1);
    expect(
      rating,
      equals(
        const Rating(
          snapId: '1234',
          totalVotes: 1337,
          ratingsBand: RatingsBand.veryGood,
          snapName: 'firefox',
        ),
      ),
    );
  });

  test('get category', () async {
    final mockClient = createMockRatingsClient(
      token: 'jwt',
      chartData: const [
        ChartData(
          rawRating: 117,
          rating: Rating(
            snapId: '4321',
            totalVotes: 117,
            ratingsBand: RatingsBand.veryGood,
            snapName: 'john',
          ),
        ),
        ChartData(
          rawRating: 104,
          rating: Rating(
            snapId: '5678',
            totalVotes: 104,
            ratingsBand: RatingsBand.veryGood,
            snapName: 'fred',
          ),
        ),
      ],
    );
    final service = RatingsService(mockClient, id: 'myId');

    final charts = await service.getChart(SnapCategoryEnum.games);
    verify(mockClient.authenticate('myId')).called(1);
    expect(
      charts,
      containsAll([
        const ChartData(
          rawRating: 117,
          rating: Rating(
            snapId: '4321',
            totalVotes: 117,
            ratingsBand: RatingsBand.veryGood,
            snapName: 'john',
          ),
        ),
        const ChartData(
          rawRating: 104,
          rating: Rating(
            snapId: '5678',
            totalVotes: 104,
            ratingsBand: RatingsBand.veryGood,
            snapName: 'fred',
          ),
        ),
      ]),
    );
  });

  test('vote', () async {
    final mockClient = createMockRatingsClient(token: 'jwt');
    final service = RatingsService(mockClient, id: 'myId');

    await service.vote(
      Vote(
        snapId: '7890',
        snapRevision: 42,
        voteUp: true,
        dateTime: DateTime(1970),
        snapName: 'thunderbird',
      ),
    );
    verify(mockClient.authenticate('myId')).called(1);
    verify(mockClient.vote('thunderbird', '7890', 42, true, 'jwt')).called(1);
  });

  test('delete', () async {
    final mockClient = createMockRatingsClient(token: 'jwt');
    final service = RatingsService(mockClient, id: 'myId');

    await service.delete();
    verify(mockClient.authenticate('myId')).called(1);
    verify(mockClient.delete('jwt')).called(1);
  });

  test('snap votes', () async {
    final mockClient = createMockRatingsClient(
      token: 'jwt',
      snapVotes: [
        Vote(
          snapId: '1111',
          snapRevision: 2,
          voteUp: true,
          dateTime: DateTime(1999),
          snapName: 'testSnap2',
        ),
      ],
    );
    final service = RatingsService(mockClient, id: 'myId');

    final votes = await service.getSnapVotes('testSnap2');
    verify(mockClient.authenticate('myId')).called(1);
    expect(
      votes,
      equals(
        [
          Vote(
            snapId: '1111',
            snapRevision: 2,
            voteUp: true,
            dateTime: DateTime(1999),
            snapName: 'testSnap2',
          ),
        ],
      ),
    );
  });
}
