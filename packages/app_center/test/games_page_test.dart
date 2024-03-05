import 'package:app_center/games.dart';
import 'package:app_center/ratings.dart';
import 'package:app_center/search.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

const snapId = 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD';
const snapRating = Rating(
  snapId: snapId,
  totalVotes: 123,
  ratingsBand: RatingsBand.good,
);

void main() {
  final ratingsModel = createMockRatingsModel(
    snapId: snapId,
    snapRating: snapRating,
  );
  final mockSearchProvider = createMockSnapSearchProvider({
    const SnapSearchParameters(query: 'testsn'): const [
      Snap(name: 'testsnap', title: 'Test Snap', downloadSize: 3),
      Snap(name: 'testsnap2', title: 'Another Test Snap', downloadSize: 1),
      Snap(name: 'testsnap3', title: 'Yet Another Test Snap', downloadSize: 2),
    ],
    const SnapSearchParameters(
      category: SnapCategoryEnum.games,
    ): const [
      Snap(
        name: 'testsnap4',
        title: 'A Cool Game',
        summary: 'This is a really cool game',
        downloadSize: 2,
        media: [
          SnapMedia(type: 'screenshot', url: 'https://example.com'),
        ],
      ),
      Snap(
        name: 'testsnap5',
        summary: 'This is another really cool game',
        downloadSize: 3,
        media: [
          SnapMedia(type: 'screenshot', url: 'https://example.com'),
        ],
      ),
    ],
    const SnapSearchParameters(category: SnapCategoryEnum.education): const [
      Snap(name: 'educational-snap', title: 'Educational Snap'),
    ],
  });

  testWidgets('Games tab - All Games button', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          snapSearchProvider
              .overrideWith((ref, arg) => mockSearchProvider(arg)),
          ratingsModelProvider.overrideWith((ref, arg) => ratingsModel)
        ],
        child: SearchPage(category: SnapCategoryEnum.games.name),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('A Cool Game'), findsOneWidget);
    expect(find.text('Educational Snap'), findsNothing);
    expect(find.text('Test Snap'), findsNothing);
  });

  group('Games tab - Carousel', () {
    testWidgets('1 app', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider
                .overrideWith((ref, arg) => mockSearchProvider(arg)),
            ratingsModelProvider.overrideWith((ref, arg) => ratingsModel)
          ],
          child: const FeaturedCarousel(
            snapAmount: 1,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('A Cool Game'), findsOne);
      expect(find.text('testsnap5'), findsNothing);
      expect(find.text('This is a really cool game'), findsOne);
      expect(find.text('This is another really cool game'), findsNothing);
    });

    testWidgets('10 apps', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider
                .overrideWith((ref, arg) => mockSearchProvider(arg)),
            ratingsModelProvider.overrideWith((ref, arg) => ratingsModel)
          ],
          child: const FeaturedCarousel(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('A Cool Game'), findsOne);
      expect(find.text('testsnap5'), findsOne);
      expect(find.text('This is a really cool game'), findsOne);
      expect(find.text('This is another really cool game'), findsOne);
    });
  });

  testWidgets('Games Tab', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(overrides: [
        snapSearchProvider.overrideWith((ref, arg) => mockSearchProvider(arg)),
        ratingsModelProvider.overrideWith((ref, arg) => ratingsModel)
      ], child: const GamesPage()),
    );

    await tester.pump();

    expect(find.text('It\'s playtime'), findsOne);
    expect(find.byType(FeaturedCarousel), findsOne);
  });
}
