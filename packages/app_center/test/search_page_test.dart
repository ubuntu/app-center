import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/search/search.dart';
import 'package:app_center/snapd/multisnap_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

const snapId = 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD';
const snapName = 'signal-desktop';
const snapRating = Rating(
  snapId: snapId,
  totalVotes: 123,
  ratingsBand: RatingsBand.good,
  snapName: snapName,
);

void main() {
  setUp(() => registerMockRatingsService(rating: snapRating));
  tearDown(resetAllServices);

  final mockSearchProvider = createMockSnapSearchProvider({
    const SnapSearchParameters(query: 'testsn'): [
      createSnap(name: 'testsnap', title: 'Test Snap', downloadSize: 3),
      createSnap(
        name: 'testsnap2',
        title: 'Another Test Snap',
        downloadSize: 1,
      ),
      createSnap(
        name: 'testsnap3',
        title: 'Yet Another Test Snap',
        downloadSize: 2,
      ),
    ],
    const SnapSearchParameters(
      query: 'testsn',
      category: SnapCategoryEnum.development,
    ): [
      createSnap(
        name: 'testsnap3',
        title: 'Yet Another Test Snap',
        downloadSize: 2,
      ),
    ],
    const SnapSearchParameters(category: SnapCategoryEnum.education): [
      createSnap(name: 'educational-snap', title: 'Educational Snap'),
    ],
    const SnapSearchParameters(category: SnapCategoryEnum.gameDev): [
      createSnap(name: 'game-engine', title: 'Game Engine'),
      createSnap(name: 'image-processor', title: 'Image Processor'),
    ],
  });
  final multiSnapModel = MockMultiSnapModel();

  testWidgets('query', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          snapSearchProvider.overrideWith(
            (ref, query) => mockSearchProvider(query),
          ),
        ],
        child: const SearchPage(query: 'testsn'),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(tester.l10n.searchPageTitle('testsn')), findsOneWidget);
    expect(
      find.widgetWithText(
        MenuButtonBuilder<SnapCategoryEnum?>,
        tester.l10n.snapCategoryAll,
      ),
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
          snapSearchProvider.overrideWith(
            (ref, query) => mockSearchProvider(query),
          ),
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
      find.widgetWithText(
        MenuButtonBuilder<SnapCategoryEnum?>,
        tester.l10n.snapCategoryDevelopment,
      ),
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
          snapSearchProvider.overrideWith(
            (ref, query) => mockSearchProvider(query),
          ),
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

  testWidgets('games-bundle', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          snapSearchProvider.overrideWith(
            (ref, query) => mockSearchProvider(query),
          ),
          multiSnapModelProvider.overrideWith((ref, arg) => multiSnapModel),
        ],
        child: const SearchPage(
          category: 'gameDev',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(tester.l10n.snapCategoryGameDev), findsOneWidget);
    expect(find.byType(MenuButtonBuilder<SnapCategoryEnum?>), findsNothing);
    expect(find.text(tester.l10n.installAll), findsOneWidget);
    expect(find.text('Game Engine'), findsOneWidget);
    expect(find.text('Image Processor'), findsOneWidget);
    expect(find.text('Test Snap'), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    verify(multiSnapModel.installAll()).called(1);
  });

  group('sort results', () {
    testWidgets('Relevance', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, query) => mockSearchProvider(query),
            ),
          ],
          child: const SearchPage(query: 'testsn'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageSortByLabel), findsOneWidget);
      expect(find.text(tester.l10n.searchPageRelevanceLabel), findsOneWidget);

      final resultCards = tester
          .widget<AppCardGrid>(find.byType(AppCardGrid))
          .appCards;
      expect(
        resultCards.map((card) => card.title.title).toList(),
        equals([
          'Test Snap',
          'Another Test Snap',
          'Yet Another Test Snap',
        ]),
      );
    });
    testWidgets('Download Size', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, query) => mockSearchProvider(query),
            ),
          ],
          child: const SearchPage(query: 'testsn'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageSortByLabel), findsOneWidget);
      await tester.tap(find.text(tester.l10n.searchPageRelevanceLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.snapSortOrderDownloadSizeAsc));
      await tester.pumpAndSettle();

      final resultCards = tester
          .widget<AppCardGrid>(find.byType(AppCardGrid))
          .appCards;
      expect(
        resultCards.map((card) => card.title.title).toList(),
        equals([
          'Another Test Snap',
          'Yet Another Test Snap',
          'Test Snap',
        ]),
      );
    });
    testWidgets('Alphabetical', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, query) => mockSearchProvider(query),
            ),
          ],
          child: const SearchPage(query: 'testsn'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageSortByLabel), findsOneWidget);
      await tester.tap(find.text(tester.l10n.searchPageRelevanceLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.snapSortOrderAlphabeticalAsc));
      await tester.pumpAndSettle();

      final resultCards = tester
          .widget<AppCardGrid>(find.byType(AppCardGrid))
          .appCards;
      expect(
        resultCards.map((card) => card.title.title).toList(),
        equals([
          'Another Test Snap',
          'Test Snap',
          'Yet Another Test Snap',
        ]),
      );
    });
  });

  group('no results', () {
    testWidgets('query', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, query) => mockSearchProvider(query),
            ),
          ],
          child: const SearchPage(query: 'foo'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text(tester.l10n.searchPageNoResults('foo')), findsOneWidget);
      expect(find.text(tester.l10n.searchPageNoResultsHint), findsOneWidget);
      expect(find.byType(AppCardGrid), findsNothing);
    });

    testWidgets('empty category', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, query) => mockSearchProvider(query),
            ),
          ],
          child: const SearchPage(query: 'foo', category: 'social'),
        ),
      );

      await tester.pumpAndSettle();
      expect(
        find.text(tester.l10n.searchPageNoResultsCategory),
        findsOneWidget,
      );
      expect(
        find.text(tester.l10n.searchPageNoResultsCategoryHint),
        findsOneWidget,
      );
      expect(find.byType(AppCardGrid), findsNothing);
    });
  });

  group('unified results', () {
    final snapSearch = createMockSnapSearchProvider({
      const SnapSearchParameters(query: 'edit'): [
        createSnap(
          name: 'editor',
          title: 'Editor Snap',
          commonIds: ['org.example.Editor'],
        ),
        createSnap(name: 'writer', title: 'Writer Snap'),
      ],
      const SnapSearchParameters(
        query: 'edit',
        category: SnapCategoryEnum.development,
      ): [
        createSnap(
          name: 'editor',
          title: 'Editor Snap',
          commonIds: ['org.example.Editor'],
        ),
      ],
      const SnapSearchParameters(query: 'many'): [
        for (final title in ['One', 'Two', 'Three', 'Four'])
          createSnap(name: title.toLowerCase(), title: title),
      ],
    });
    final debSearch = createMockDebSearchProvider({
      'edit': [
        createAppstreamComponent(
          id: 'org.example.Notes',
          name: 'Notes Deb',
          categories: ['Office'],
        ),
        createAppstreamComponent(id: 'org.example.Editor', name: 'Editor Deb'),
        createAppstreamComponent(
          id: 'org.example.Ide',
          name: 'IDE Deb',
          categories: ['Development'],
        ),
      ],
    });

    Future<List<RouteSettings>> pumpUnifiedSearch(
      WidgetTester tester, {
      String query = 'edit',
    }) async {
      final routes = <RouteSettings>[];
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith((ref, query) => snapSearch(query)),
            appstreamResultsProvider.overrideWith(
              (ref, query) => debSearch(query).first,
            ),
          ],
          child: Navigator(
            onGenerateRoute: (settings) {
              routes.add(settings);
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => settings.name == Navigator.defaultRouteName
                    ? SearchPage(query: query, unifiedResults: true)
                    : const SizedBox.shrink(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      return routes;
    }

    List<String> cardTitles(WidgetTester tester) => [
      for (final card
          in tester.widget<AppCardGrid>(find.byType(AppCardGrid)).appCards)
        card.title.title,
    ];

    testWidgets('shows more results on request', (tester) async {
      await pumpUnifiedSearch(tester, query: 'many');
      final showMore = find.text(tester.l10n.searchPageShowMoreLabel);

      expect(cardTitles(tester), ['One', 'Two', 'Three']);

      await tester.scrollUntilVisible(
        showMore,
        200,
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(showMore);
      await tester.pumpAndSettle();

      expect(cardTitles(tester), ['One', 'Two', 'Three', 'Four']);
      expect(showMore, findsNothing);
    });

    testWidgets('lists snaps, then debs without a snap', (tester) async {
      await pumpUnifiedSearch(tester);

      expect(cardTitles(tester), [
        'Editor Snap',
        'Writer Snap',
        'Notes Deb',
        'IDE Deb',
      ]);
      Finder icon(String title, IconData icon) => find.descendant(
        of: find.widgetWithText(AppCard, title),
        matching: find.byIcon(icon),
      );
      expect(icon('Editor Snap', YaruIcons.package_snap), findsOneWidget);
      expect(icon('Editor Snap', YaruIcons.package_deb), findsOneWidget);
      expect(icon('Writer Snap', YaruIcons.package_deb), findsNothing);
      expect(icon('Notes Deb', YaruIcons.package_snap), findsNothing);
      expect(icon('Notes Deb', YaruIcons.package_deb), findsOneWidget);
      expect(
        find.widgetWithText(
          MenuButtonBuilder<PackageFormat?>,
          tester.l10n.packageFormatAllLabel,
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          MenuButtonBuilder<SnapCategoryEnum?>,
          tester.l10n.snapCategoryAll,
        ),
        findsOneWidget,
      );
    });

    testWidgets('puts the filters beside the title on wide pages', (
      tester,
    ) async {
      await pumpUnifiedSearch(tester);
      double centerOf(String text) => tester.getCenter(find.text(text)).dy;
      final title = tester.l10n.searchPageTitle('edit');
      final filterBy = tester.l10n.searchPageFilterByLabel;

      expect(centerOf(filterBy), greaterThan(centerOf(title)));

      addTearDown(tester.view.reset);
      tester.view.physicalSize =
          const Size(1400, 800) * tester.view.devicePixelRatio;
      await tester.pumpAndSettle();

      expect(centerOf(filterBy), closeTo(centerOf(title), 1));
    });

    testWidgets('wraps the filters with large text', (tester) async {
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.platformDispatcher.textScaleFactorTestValue = 2;

      await pumpUnifiedSearch(tester);

      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.text(tester.l10n.searchPageFilterByLabel)).dy,
        greaterThan(
          tester.getCenter(find.text(tester.l10n.searchPageSortByLabel)).dy,
        ),
      );
    });

    testWidgets('sorts snaps and debs together', (tester) async {
      await pumpUnifiedSearch(tester);

      await tester.tap(find.text(tester.l10n.snapSortOrderRelevance));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.snapSortOrderAlphabeticalAsc));
      await tester.pumpAndSettle();

      expect(cardTitles(tester), [
        'Editor Snap',
        'IDE Deb',
        'Notes Deb',
        'Writer Snap',
      ]);
    });

    testWidgets('filters by package format', (tester) async {
      await pumpUnifiedSearch(tester);

      await tester.tap(find.text(tester.l10n.packageFormatAllLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.packageFormatSnapLabel).last);
      await tester.pumpAndSettle();

      expect(cardTitles(tester), ['Editor Snap', 'Writer Snap']);

      await tester.tap(find.text(tester.l10n.packageFormatSnapLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.packageFormatDebLabel).last);
      await tester.pumpAndSettle();

      expect(cardTitles(tester), ['Notes Deb', 'Editor Deb', 'IDE Deb']);
    });

    testWidgets('filters by category', (tester) async {
      await pumpUnifiedSearch(tester);

      await tester.tap(find.text(tester.l10n.snapCategoryAll));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tester.l10n.snapCategoryDevelopment));
      await tester.pumpAndSettle();

      expect(cardTitles(tester), ['Editor Snap', 'IDE Deb']);
    });

    testWidgets('opens a snap result with its deb', (tester) async {
      final routes = await pumpUnifiedSearch(tester);

      await tester.tap(find.text('Editor Snap'));
      await tester.pumpAndSettle();

      expect(
        routes.last.name,
        StoreRoutes.namedSearchSnap(name: 'editor', query: 'edit'),
      );
      final entry = routes.last.arguments! as AppDetailsEntry;
      expect(
        entry.provisionalIdentity.sourceKeys.map((key) => key.value),
        ['snap:editor', 'deb:org.example.Editor'],
      );
    });

    testWidgets('opens a deb result', (tester) async {
      final routes = await pumpUnifiedSearch(tester);

      await tester.tap(find.text('Notes Deb'));
      await tester.pumpAndSettle();

      expect(routes.last.name, StoreRoutes.namedDeb(id: 'org.example.Notes'));
    });
  });
}
