import 'package:app_store/search.dart';
import 'package:app_store/snapd.dart';
import 'package:app_store/src/search/search_provider.dart';
import 'package:app_store/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  final mockSearchProvider = createMockSearchProvider({
    'testsnap': const [
      Snap(name: 'testsnap', title: 'Test Snap', downloadSize: 3),
      Snap(name: 'testsnap2', title: 'Another Test Snap', downloadSize: 1),
      Snap(name: 'testsnap3', title: 'Yet Another Test Snap', downloadSize: 2),
    ]
  });
  testWidgets('show results', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          searchProvider.overrideWith((ref, query) => mockSearchProvider(query))
        ],
        child: const SearchPage(query: 'testsn'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(tester.l10n.searchPageTitle('testsn')), findsOneWidget);
    expect(find.text('Test Snap'), findsOneWidget);
    expect(find.text('Another Test Snap'), findsOneWidget);
  });

  group('sort results', () {
    testWidgets('Relevance', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            searchProvider
                .overrideWith((ref, query) => mockSearchProvider(query))
          ],
          child: const SearchPage(query: 'testsn'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageSortByLabel), findsOneWidget);
      expect(find.text(tester.l10n.searchPageRelevanceLabel), findsOneWidget);

      final resultSnaps = tester.widget<SnapGrid>(find.byType(SnapGrid)).snaps;
      expect(
          resultSnaps.map((snap) => snap.titleOrName).toList(),
          equals([
            'Test Snap',
            'Another Test Snap',
            'Yet Another Test Snap',
          ]));
    });
    testWidgets('Download Size', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            searchProvider
                .overrideWith((ref, query) => mockSearchProvider(query))
          ],
          child: const SearchPage(query: 'testsn'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageSortByLabel), findsOneWidget);
      await tester.tap(find.text(tester.l10n.searchPageRelevanceLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.searchPageDownloadSizeLabel));
      await tester.pumpAndSettle();

      final resultSnaps = tester.widget<SnapGrid>(find.byType(SnapGrid)).snaps;
      expect(
          resultSnaps.map((snap) => snap.titleOrName).toList(),
          equals([
            'Another Test Snap',
            'Yet Another Test Snap',
            'Test Snap',
          ]));
    });
    testWidgets('Alphabetical', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            searchProvider
                .overrideWith((ref, query) => mockSearchProvider(query))
          ],
          child: const SearchPage(query: 'testsn'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageSortByLabel), findsOneWidget);
      await tester.tap(find.text(tester.l10n.searchPageRelevanceLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.searchPageAlphabeticalLabel));
      await tester.pumpAndSettle();

      final resultSnaps = tester.widget<SnapGrid>(find.byType(SnapGrid)).snaps;
      expect(
          resultSnaps.map((snap) => snap.titleOrName).toList(),
          equals([
            'Another Test Snap',
            'Test Snap',
            'Yet Another Test Snap',
          ]));
    });
  });
}
