import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

const snapId = 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD';
const snapName = 'signal-desktop';
const snapRating = Rating(
  snapId: snapId,
  totalVotes: 123,
  ratingsBand: RatingsBand.good,
  snapName: snapName,
);

final snap = createSnap(
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

  group('accessibility', () {
    testWidgets('AppCard with onTap has button semantics', (tester) async {
      await tester.pumpApp(
        (_) => AppCard.fromSnap(
          snap: snap,
          onTap: () {},
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.button == true,
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('AppCard excludes icon from semantics', (tester) async {
      await tester.pumpApp(
        (_) => AppCard.fromSnap(
          snap: snap,
        ),
      );
      await tester.pumpAndSettle();

      final excludeSemanticsFinder = find.byType(ExcludeSemantics);
      expect(excludeSemanticsFinder, findsWidgets);
    });
  });
}
