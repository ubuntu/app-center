import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/search/search_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });

  group('unifiedSearchProvider', () {
    const query = 'edit';

    // Snap search fails when [snaps] is null.
    Future<AsyncValue<List<UnifiedSearchResult>>> search({
      required List<AppstreamComponent> debs,
      List<Snap>? snaps,
      SnapCategoryEnum? category,
      SnapSortOrder? sortOrder,
    }) async {
      final parameters = (query: query, category: category);
      final container = createContainer(
        overrides: [
          snapSearchProvider.overrideWith(
            (ref, _) => snaps == null
                ? Stream.error(Exception('offline'))
                : Stream.value(snaps),
          ),
          appstreamSearchProvider.overrideWith((ref, _) => Stream.value(debs)),
        ],
      );
      container.read(snapSortOrderProvider.notifier).state = sortOrder;
      container.listen(unifiedSearchProvider(parameters), (_, _) {});
      await container
          .read(
            snapSearchProvider(
              SnapSearchParameters(query: query, category: category),
            ).future,
          )
          .catchError((_) => <Snap>[]);
      await container.read(appstreamSearchProvider(query).future);
      return container.read(unifiedSearchProvider(parameters));
    }

    test('merges the top 3 snaps with the top 3 debs', () async {
      final results = await search(
        snaps: [
          createSnap(name: 's1', commonIds: ['org.example.One']),
          createSnap(name: 's2'),
          createSnap(name: 's3'),
          createSnap(name: 's4', commonIds: ['org.example.Four']),
        ],
        debs: [
          _deb('org.example.Four'),
          _deb('org.example.One'),
          _deb('org.example.Two'),
          _deb('org.example.Three'),
        ],
      );

      expect(_pairs(results.requireValue), [
        ('s1', 'org.example.One'),
        ('s2', null),
        ('s3', null),
        (null, 'org.example.Four'),
        (null, 'org.example.Two'),
      ]);
    });

    test('sorts the top snaps without picking other ones', () async {
      final results = await search(
        snaps: [
          createSnap(name: 'b'),
          createSnap(name: 'c'),
          createSnap(name: 'a'),
          createSnap(name: 'aa'),
        ],
        debs: [],
        sortOrder: SnapSortOrder.alphabeticalAsc,
      );

      expect(_pairs(results.requireValue), [
        ('a', null),
        ('b', null),
        ('c', null),
      ]);
    });

    test('shows the other results when one source fails', () async {
      final results = await search(debs: [_deb('org.example.Notes')]);

      expect(_pairs(results.requireValue), [(null, 'org.example.Notes')]);
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
          _deb('org.example.Editor', categories: ['Development']),
          _deb('org.example.Ide', categories: ['Development']),
          _deb('org.example.Game', categories: ['Game']),
        ],
        category: SnapCategoryEnum.development,
      );

      expect(_pairs(results.requireValue), [
        ('editor', 'org.example.Editor'),
        (null, 'org.example.Ide'),
      ]);
    });
  });
}
