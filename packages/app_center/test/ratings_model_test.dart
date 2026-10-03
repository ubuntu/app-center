import 'package:app_center/ratings/ratings.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  final snap = createSnap(
    name: 'firefox',
    id: '1234',
    revision: 42,
  );

  setUp(() {
    registerMockSnapdService(storeSnap: snap);
    registerMockRatingsService(
      rating: const Rating(
        snapId: '1234',
        totalVotes: 1337,
        ratingsBand: RatingsBand.veryGood,
        snapName: 'firefox',
      ),
      snapVotes: [
        Vote(
          snapId: '1234',
          snapRevision: 42,
          voteUp: true,
          dateTime: DateTime(1970),
          snapName: 'firefox',
        ),
      ],
    );
  });

  tearDown(resetAllServices);

  test('init', () async {
    final container = createContainer();
    final ratingsData = await container.read(
      ratingsModelProvider(snap.name).future,
    );
    expect(
      ratingsData.rating,
      equals(
        const Rating(
          snapId: '1234',
          totalVotes: 1337,
          ratingsBand: RatingsBand.veryGood,
          snapName: 'firefox',
        ),
      ),
    );
    expect(ratingsData.voteStatus, equals(VoteStatus.up));
  });

  test('cast vote', () async {
    final container = createContainer();
    final mockService = getService<RatingsService>();
    final model = container.read(ratingsModelProvider(snap.name).notifier);
    container.listen(ratingsModelProvider(snap.name), (_, __) {});
    await container.read(ratingsModelProvider(snap.name).future);
    await withClock(
      Clock.fixed(DateTime(1984)),
      () => model.castVote(VoteStatus.down),
    );
    verify(
      mockService.vote(
        Vote(
          dateTime: DateTime(1984),
          snapId: '1234',
          snapRevision: 42,
          voteUp: false,
          snapName: 'firefox',
        ),
      ),
    ).called(1);
  });

  group('with a pending update', () {
    final installed = createSnap(name: 'firefox', id: '1234', revision: 42);
    final inStore = createSnap(name: 'firefox', id: '1234', revision: 99);

    setUp(() async {
      await resetAllServices();
      registerMockSnapdService(localSnap: installed, storeSnap: inStore);
      registerMockRatingsService(
        rating: const Rating(
          snapId: '1234',
          totalVotes: 1337,
          ratingsBand: RatingsBand.veryGood,
          snapName: 'firefox',
        ),
        snapVotes: [
          Vote(
            snapId: '1234',
            snapRevision: 42,
            voteUp: true,
            dateTime: DateTime(1970),
            snapName: 'firefox',
          ),
        ],
      );
    });

    test('rates the installed revision, not the one in the store', () async {
      final container = createContainer();
      final ratingsData = await container.read(
        ratingsModelProvider('firefox').future,
      );

      expect(ratingsData.snapRevision, equals(42));
      // The earlier vote was cast against the installed revision, so it is
      // found instead of the buttons coming up unset.
      expect(ratingsData.voteStatus, equals(VoteStatus.up));
    });

    test('casts the vote against the installed revision', () async {
      final container = createContainer();
      final mockService = getService<RatingsService>();
      final model = container.read(ratingsModelProvider('firefox').notifier);
      container.listen(ratingsModelProvider('firefox'), (_, __) {});
      await container.read(ratingsModelProvider('firefox').future);

      await withClock(
        Clock.fixed(DateTime(1984)),
        () => model.castVote(VoteStatus.down),
      );

      verify(
        mockService.vote(
          Vote(
            dateTime: DateTime(1984),
            snapId: '1234',
            snapRevision: 42,
            voteUp: false,
            snapName: 'firefox',
          ),
        ),
      ).called(1);
    });
  });
}
