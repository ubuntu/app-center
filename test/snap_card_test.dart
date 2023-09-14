import 'package:app_center/src/ratings/exports.dart';
import 'package:app_center/src/ratings/ratings_model.dart';
import 'package:app_center/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

const snapId = "r4LxMVp7zWramXsJQAKdamxy6TAWlaDD";
const snapRating = Rating(
  snapId: snapId,
  totalVotes: 123,
  ratingsBand: RatingsBand.good,
);

const snap = Snap(
    name: 'testsnap',
    id: 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD',
    summary: 'Its a summary!');

void main() {
  final ratingsModel = createMockRatingsModel(
    snapId: snapId,
    snapRating: snapRating,
  );

  testWidgets('query', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          ratingsModelProvider.overrideWith((ref, arg) => ratingsModel),
        ],
        child: SnapCard(snap: snap),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('testsnap'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text(' | 123 votes'), findsOneWidget);
  });
}
