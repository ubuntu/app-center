import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';
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

Snap createValidatedSnap(String validation) => createSnap(
  name: 'testsnap',
  id: snapId,
  summary: 'Its a summary!',
  publisher: SnapPublisher(
    id: 'p',
    displayName: 'Publisher',
    validation: validation,
  ),
);

Finder findSemanticsContaining(String text) =>
    find.bySemanticsLabel(RegExp(RegExp.escape(text)));

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

  testWidgets('explains and announces a verified publisher', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpApp(
      (_) => ProviderScope(
        child: AppCard.fromSnap(snap: createValidatedSnap('verified')),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = tester.l10n;

    expect(
      find.byTooltip(l10n.appDetailsVerifiedPublisherTooltip),
      findsOneWidget,
    );
    expect(
      findSemanticsContaining(
        '${l10n.appCardPublisherSemanticLabel('Publisher')} '
        '${l10n.appDetailsVerifiedPublisherSemanticLabel}.',
      ),
      findsOneWidget,
    );
    expect(
      findSemanticsContaining(l10n.appDetailsVerifiedPublisherTooltip),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('ranked card announces a starred publisher', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpApp(
      (_) => ProviderScope(
        child: RankedAppCard.fromRankedSnap(
          snap: createValidatedSnap('starred'),
          rank: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = tester.l10n;

    expect(
      find.byTooltip(l10n.appDetailsStarredPublisherTooltip),
      findsOneWidget,
    );
    expect(
      findSemanticsContaining(
        '${l10n.appCardPublisherSemanticLabel('Publisher')} '
        '${l10n.appDetailsStarredPublisherSemanticLabel}.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
