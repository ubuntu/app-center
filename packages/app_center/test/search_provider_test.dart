import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/search/search_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

AppstreamComponent _deb(
  String id, {
  String? package,
  List<String> desktopIds = const [],
  List<String> provides = const [],
  List<String> categories = const [],
}) => AppstreamComponent(
  id: id,
  type: AppstreamComponentType.desktopApplication,
  package: package ?? id,
  name: {'C': id},
  summary: const {'C': ''},
  categories: categories,
  launchables: [
    for (final desktopId in desktopIds) AppstreamLaunchableDesktopId(desktopId),
  ],
  provides: [for (final alias in provides) AppstreamProvidesId(alias)],
);

List<(String?, String?)> _pairs(List<UnifiedSearchResult> results) => [
  for (final result in results) (result.snap?.name, result.deb?.id),
];

void main() {
  group('UnifiedSearchResult', () {
    String folded(UnifiedSearchResult result) =>
        result.fold(onSnap: (snap) => 'snap', onDeb: (deb) => 'deb');

    test('folds to the snap when it has one', () {
      final snap = createSnap(name: 'vlc', title: 'VLC');

      expect(folded(UnifiedSearchResult(snap: snap)), 'snap');
      expect(
        folded(UnifiedSearchResult(snap: snap, deb: _deb('org.videolan.vlc'))),
        'snap',
      );
      expect(
        UnifiedSearchResult(snap: snap, deb: _deb('org.videolan.vlc')).title,
        'VLC',
      );
    });

    test('folds to the deb otherwise', () {
      final result = UnifiedSearchResult(deb: _deb('org.videolan.vlc'));

      expect(folded(result), 'deb');
      expect(result.title, 'org.videolan.vlc');
    });
  });

  group('mergeSearchResults', () {
    test('keeps snap order and appends unmatched debs in order', () {
      final results = mergeSearchResults(
        [
          createSnap(name: 'gimp', commonIds: ['org.gimp.GIMP']),
          createSnap(name: 'krita'),
          createSnap(name: 'vlc', commonIds: ['org.videolan.vlc']),
        ],
        [
          _deb('org.kde.kdenlive'),
          _deb('org.videolan.vlc', package: 'vlc'),
          _deb('org.gimp.GIMP', package: 'gimp'),
          _deb('org.inkscape.Inkscape'),
        ],
      );

      expect(_pairs(results), [
        ('gimp', 'org.gimp.GIMP'),
        ('krita', null),
        ('vlc', 'org.videolan.vlc'),
        (null, 'org.kde.kdenlive'),
        (null, 'org.inkscape.Inkscape'),
      ]);
    });

    test('matches by desktop file, alias and package name', () {
      final results = mergeSearchResults(
        [
          createSnap(
            name: 'code-editor',
            apps: const [
              SnapApp(
                name: 'editor',
                desktopFile: 'code-editor_texteditor.desktop',
              ),
            ],
          ),
          createSnap(name: 'firefox'),
          createSnap(
            name: 'shotwell',
            apps: const [SnapApp(name: 'shotwell')],
          ),
        ],
        [
          _deb('org.gnome.Shotwell', package: 'shotwell'),
          _deb(
            'org.mozilla.Firefox',
            package: 'firefox-esr',
            provides: ['firefox'],
          ),
          _deb(
            'org.example.TextEditor',
            package: 'text-editor',
            desktopIds: ['texteditor.desktop'],
          ),
        ],
      );

      expect(_pairs(results), [
        ('code-editor', 'org.example.TextEditor'),
        ('firefox', 'org.mozilla.Firefox'),
        ('shotwell', 'org.gnome.Shotwell'),
      ]);
    });

    test('gives a deb to its strongest match', () {
      final results = mergeSearchResults(
        [
          createSnap(
            name: 'editor-a',
            apps: const [
              SnapApp(name: 'editor', desktopFile: 'editor-a_editor.desktop'),
            ],
          ),
          createSnap(name: 'editor-b', commonIds: ['org.example.Editor']),
        ],
        [
          _deb('org.example.Editor', desktopIds: ['editor.desktop']),
        ],
      );

      expect(_pairs(results), [
        ('editor-a', null),
        ('editor-b', 'org.example.Editor'),
      ]);
    });

    test('gives a deb to one snap only', () {
      final results = mergeSearchResults(
        [
          createSnap(name: 'one', commonIds: ['org.example.App']),
          createSnap(name: 'two', commonIds: ['org.example.App']),
        ],
        [_deb('org.example.App')],
      );

      expect(_pairs(results), [
        ('one', 'org.example.App'),
        ('two', null),
      ]);
    });

    test('matches store snaps, which list no apps, by package name', () {
      final results = mergeSearchResults(
        [createSnap(name: 'shotwell', type: 'app')],
        [_deb('org.gnome.Shotwell.desktop', package: 'shotwell')],
      );

      expect(_pairs(results), [('shotwell', 'org.gnome.Shotwell.desktop')]);
    });
  });

  group('pageSearchResults', () {
    List<List<(String?, String?)>> pages(
      List<Snap> snaps,
      List<AppstreamComponent> debs, {
      bool Function(AppstreamComponent)? showDeb,
    }) => [
      for (final page in pageSearchResults(snaps, debs, showDeb: showDeb))
        _pairs(page),
    ];

    test('pages through the top snaps and debs, matched across all', () {
      expect(
        pages(
          [
            createSnap(name: 's1', commonIds: ['org.example.One']),
            createSnap(name: 's2'),
            createSnap(name: 's3'),
            createSnap(name: 's4', commonIds: ['org.example.Four']),
          ],
          [
            _deb('org.example.Four'),
            _deb('org.example.One'),
            _deb('org.example.Two'),
            _deb('org.example.Three'),
          ],
        ),
        [
          [
            ('s1', 'org.example.One'),
            ('s2', null),
            ('s3', null),
            ('s4', 'org.example.Four'),
            (null, 'org.example.Two'),
          ],
          [(null, 'org.example.Three')],
        ],
      );
    });

    test('pairs hidden debs with snaps without showing them alone', () {
      expect(
        pages(
          [
            createSnap(name: 'vlc', commonIds: ['org.videolan.vlc']),
          ],
          [
            _deb('org.videolan.vlc'),
            _deb('org.example.Hidden'),
            _deb('org.example.Shown'),
          ],
          showDeb: (deb) => deb.id == 'org.example.Shown',
        ),
        [
          [('vlc', 'org.videolan.vlc'), (null, 'org.example.Shown')],
        ],
      );
    });

    test('skips pages without new apps', () {
      expect(
        pages(
          [
            for (final id in ['A', 'B', 'C'])
              createSnap(name: id, commonIds: ['org.example.$id']),
          ],
          [
            for (final id in ['D', 'E', 'F', 'A', 'B', 'C'])
              _deb('org.example.$id'),
          ],
        ),
        hasLength(1),
      );
    });
  });

  group('shownSearchResults', () {
    final pages = <List<UnifiedSearchResult>>[
      [
        UnifiedSearchResult(
          snap: createSnap(name: 'b', title: 'b'),
        ),
        UnifiedSearchResult(
          snap: createSnap(name: 'c', title: 'c'),
        ),
      ],
      [UnifiedSearchResult(deb: _deb('a'))],
    ];
    List<String?> shown(int shownPages, SnapSortOrder? order) => [
      for (final (snap, deb) in _pairs(
        shownSearchResults(pages, shownPages, order),
      ))
        snap ?? deb,
    ];

    test('keeps the revealed pages for relevance', () {
      expect(shown(1, null), ['b', 'c']);
      expect(shown(2, null), ['b', 'c', 'a']);
    });

    test('sorts all results before taking the revealed count', () {
      expect(shown(1, SnapSortOrder.alphabeticalAsc), ['a', 'b']);
      expect(shown(2, SnapSortOrder.alphabeticalAsc), ['a', 'b', 'c']);
    });
  });

  group('searchResultEntry', () {
    List<String> sourcesOf(AppDetailsEntry entry) => [
      for (final key in entry.provisionalIdentity.sourceKeys) key.value,
    ];

    test('carries the matched pair', () {
      final entry = searchResultEntry(
        UnifiedSearchResult(
          snap: createSnap(name: 'shotwell', type: 'app'),
          deb: _deb('org.gnome.Shotwell.desktop', package: 'shotwell'),
        ),
      );

      expect(entry, isA<IdentityEntry>());
      expect(sourcesOf(entry), [
        'snap:shotwell',
        'deb:org.gnome.Shotwell.desktop',
      ]);
    });

    test('names a single source otherwise', () {
      expect(
        searchResultEntry(UnifiedSearchResult(snap: createSnap(name: 'vlc'))),
        const AppDetailsEntry.snap('vlc'),
      );
      expect(
        searchResultEntry(UnifiedSearchResult(deb: _deb('org.videolan.vlc'))),
        const AppDetailsEntry.debComponent('org.videolan.vlc'),
      );
    });
  });

  group('suggestSearchResults', () {
    test('picks an app in both formats, a snap and a deb', () {
      final results = suggestSearchResults(
        [
          createSnap(name: 's1'),
          createSnap(name: 's2', commonIds: ['org.example.Both']),
          createSnap(name: 's3'),
        ],
        [_deb('org.example.D1'), _deb('org.example.Both')],
      );

      expect(_pairs(results), [
        ('s2', 'org.example.Both'),
        ('s1', null),
        (null, 'org.example.D1'),
      ]);
    });

    test('picks 2 snaps and a deb without an app in both formats', () {
      final results = suggestSearchResults(
        [
          createSnap(name: 's1'),
          createSnap(name: 's2'),
          createSnap(name: 's3'),
        ],
        [_deb('org.example.D1'), _deb('org.example.D2')],
      );

      expect(_pairs(results), [
        ('s1', null),
        ('s2', null),
        (null, 'org.example.D1'),
      ]);
    });

    test('fills free slots with other results', () {
      final results = suggestSearchResults(
        [],
        [
          for (final id in ['D1', 'D2', 'D3', 'D4']) _deb('org.example.$id'),
        ],
      );

      expect(_pairs(results), [
        (null, 'org.example.D1'),
        (null, 'org.example.D2'),
        (null, 'org.example.D3'),
      ]);
    });
  });

  group('sortSearchResults', () {
    final results = <UnifiedSearchResult>[
      UnifiedSearchResult(
        snap: createSnap(name: 'b', title: 'b', downloadSize: 20),
      ),
      UnifiedSearchResult(deb: _deb('a')),
      UnifiedSearchResult(
        snap: createSnap(name: 'c', title: 'c', downloadSize: 10),
      ),
    ];
    List<String?> sorted(SnapSortOrder order) => [
      for (final (snap, deb) in _pairs(sortSearchResults(results, order)))
        snap ?? deb,
    ];

    test('sorts snaps and debs together by name', () {
      expect(sorted(SnapSortOrder.alphabeticalAsc), ['a', 'b', 'c']);
      expect(sorted(SnapSortOrder.alphabeticalDesc), ['c', 'b', 'a']);
    });

    test('sorts by size with debs last', () {
      expect(sorted(SnapSortOrder.downloadSizeAsc), ['c', 'b', 'a']);
      expect(sorted(SnapSortOrder.downloadSizeDesc), ['b', 'c', 'a']);
    });
  });

  group('unifiedSearchProvider', () {
    const query = 'edit';

    // Snap search fails when [snaps] is null.
    Future<AsyncValue<List<List<UnifiedSearchResult>>>> search({
      required List<AppstreamComponent> debs,
      List<Snap>? snaps,
      SnapCategoryEnum? category,
    }) async {
      final parameters = (query: query, category: category);
      final container = createContainer(
        overrides: [
          snapSearchProvider.overrideWith(
            (ref, _) => snaps == null
                ? Stream.error(Exception('offline'))
                : Stream.value(snaps),
          ),
          appstreamResultsProvider.overrideWith((ref, _) async => debs),
        ],
      );
      container.listen(unifiedSearchProvider(parameters), (_, _) {});
      await container
          .read(
            snapSearchProvider(
              SnapSearchParameters(query: query, category: category),
            ).future,
          )
          .catchError((_) => <Snap>[]);
      await container.read(appstreamResultsProvider(query).future);
      return container.read(unifiedSearchProvider(parameters));
    }

    test('waits for AppStream to load', () async {
      final loaded = Completer<void>();
      final appstream = createMockAppstreamService(initialized: false);
      when(appstream.init()).thenAnswer((_) => loaded.future);
      when(
        appstream.search(query),
      ).thenAnswer((_) async => [_deb('org.example.Notes')]);
      const parameters = (query: query, category: null);
      final container = createContainer(
        overrides: [
          snapSearchProvider.overrideWith((ref, _) => Stream.value([])),
        ],
      );
      container.listen(unifiedSearchProvider(parameters), (_, _) {});
      await container.read(
        snapSearchProvider(const SnapSearchParameters(query: query)).future,
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(unifiedSearchProvider(parameters)).isLoading,
        isTrue,
      );

      loaded.complete();
      await container.read(appstreamResultsProvider(query).future);

      expect(
        _pairs(
          container.read(unifiedSearchProvider(parameters)).requireValue.single,
        ),
        [(null, 'org.example.Notes')],
      );
    });

    test('shows the other results when one source fails', () async {
      final results = await search(debs: [_deb('org.example.Notes')]);

      expect(_pairs(results.requireValue.single), [
        (null, 'org.example.Notes'),
      ]);
    });

    test('fails when a source fails and there are no results', () async {
      final results = await search(debs: []);

      expect(results.hasError, isTrue);
    });

    test('keeps only debs of the selected category', () async {
      final results = await search(
        snaps: [
          createSnap(name: 'editor', commonIds: ['org.example.Editor']),
        ],
        debs: [
          _deb('org.example.Editor'),
          _deb('org.example.Ide', categories: ['Development']),
          _deb('org.example.Game', categories: ['Game']),
        ],
        category: SnapCategoryEnum.development,
      );

      expect(_pairs(results.requireValue.single), [
        ('editor', 'org.example.Editor'),
        (null, 'org.example.Ide'),
      ]);
    });
  });
}
