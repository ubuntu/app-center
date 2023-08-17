import 'package:app_store/search.dart';
import 'package:app_store/snapd.dart';
import 'package:app_store/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

import 'test_utils.dart';

void main() {
  final mockSearchProvider = createMockSearchProvider({
    const SnapSearchParameters(query: 'testsn'): const [
      Snap(name: 'testsnap', title: 'Test Snap', downloadSize: 3),
      Snap(name: 'testsnap2', title: 'Another Test Snap', downloadSize: 1),
      Snap(name: 'testsnap3', title: 'Yet Another Test Snap', downloadSize: 2),
    ],
    const SnapSearchParameters(
      query: 'testsn',
      category: SnapCategoryEnum.development,
    ): const [
      Snap(name: 'testsnap3', title: 'Yet Another Test Snap', downloadSize: 2),
    ],
    const SnapSearchParameters(category: SnapCategoryEnum.education): const [
      Snap(name: 'educational-snap', title: 'Educational Snap'),
    ],
  });
  testWidgets('query', (tester) async {
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
    expect(
      find.widgetWithText(
          MenuButtonBuilder<SnapCategoryEnum?>, tester.l10n.snapCategoryAll),
      findsOneWidget,
    );
    expect(find.text('Test Snap'), findsOneWidget);
    expect(find.text('Another Test Snap'), findsOneWidget);
    expect(find.text('Yet Another Test Snap'), findsOneWidget);
  });

  testWidgets('query + category', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          searchProvider.overrideWith((ref, query) => mockSearchProvider(query))
        ],
        child: const SearchPage(
          query: 'testsn',
          category: 'development',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(tester.l10n.searchPageTitle('testsn')), findsOneWidget);
    expect(
      find.widgetWithText(MenuButtonBuilder<SnapCategoryEnum?>,
          tester.l10n.snapCategoryDevelopment),
      findsOneWidget,
    );
    expect(find.text('Test Snap'), findsNothing);
    expect(find.text('Another Test Snap'), findsNothing);
    expect(find.text('Yet Another Test Snap'), findsOneWidget);
  });

  testWidgets('category', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          searchProvider.overrideWith((ref, query) => mockSearchProvider(query))
        ],
        child: const SearchPage(
          category: 'education',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(tester.l10n.snapCategoryEducation), findsOneWidget);
    expect(find.byType(MenuButtonBuilder<SnapCategoryEnum?>), findsNothing);
    expect(find.text('Test Snap'), findsNothing);
    expect(find.text('Another Test Snap'), findsNothing);
    expect(find.text('Yet Another Test Snap'), findsNothing);
    expect(find.text('Educational Snap'), findsOneWidget);
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

      final resultSnaps =
          tester.widget<SnapCardGrid>(find.byType(SnapCardGrid)).snaps;
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

      final resultSnaps =
          tester.widget<SnapCardGrid>(find.byType(SnapCardGrid)).snaps;
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

      final resultSnaps =
          tester.widget<SnapCardGrid>(find.byType(SnapCardGrid)).snaps;
      expect(
          resultSnaps.map((snap) => snap.titleOrName).toList(),
          equals([
            'Another Test Snap',
            'Test Snap',
            'Yet Another Test Snap',
          ]));
    });
  });

  group('no results', () {
    testWidgets('query', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            searchProvider
                .overrideWith((ref, query) => mockSearchProvider(query))
          ],
          child: const SearchPage(query: 'foo'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageNoResults('foo')), findsOneWidget);
      expect(find.text(tester.l10n.searchPageNoResultsHint), findsOneWidget);
      expect(find.byType(SnapCardGrid), findsNothing);
    });

    testWidgets('empty category', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            searchProvider
                .overrideWith((ref, query) => mockSearchProvider(query))
          ],
          child: const SearchPage(category: 'social'),
        ),
      );

      await tester.pumpAndSettle();
      expect(
          find.text(tester.l10n.searchPageNoResultsCategory), findsOneWidget);
      expect(find.text(tester.l10n.searchPageNoResultsHint), findsOneWidget);
      expect(find.byType(SnapCardGrid), findsNothing);
    });
  });
}
