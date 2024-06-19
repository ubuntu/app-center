import 'package:app_center/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

const snapId = 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD';
const snapRating = Rating(
  snapId: snapId,
  totalVotes: 123,
  ratingsBand: RatingsBand.good,
);

const snap = Snap(
  name: 'testsnap',
  id: 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD',
  summary: 'Its a summary!',
);

void main() {
  setUp(() {
    registerMockSnapdService(storeSnap: snap);
    registerMockRatingsService(rating: snapRating, snapVotes: []);
  });
  tearDown(resetAllServices);

  testWidgets('query', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        child: AppCard.fromSnap(snap: snap),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('testsnap'), findsOneWidget);
    expect(find.text(tester.l10n.snapRatingsBandGood), findsOneWidget);
    expect(
      find.text(' | ${tester.l10n.snapRatingsVotes(123)}'),
      findsOneWidget,
    );
  });
}
