import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/search/search.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';

import 'test_utils.dart';

abstract class StringCallback {
  void call(String? arg) {}
}

class MockStringCallback extends Mock implements StringCallback {}

void main() {
  final mockSnapSearchProvider = createMockSnapSearchProvider({
    const SnapSearchParameters(query: 'testsn'): [
      createSnap(name: 'testsnap', title: 'Test Snap'),
      createSnap(name: 'testsnap2', title: 'Another Test Snap'),
    ],
  });

  final mockDebSearchProvider = createMockDebSearchProvider({
    'testsn': const [
      AppstreamComponent(
        id: 'testsnImeanDeb.desktop',
        type: AppstreamComponentType.desktopApplication,
        package: 'testsn',
        name: {'C': 'Test Sn..I mean deb'},
        summary: {'C': 'The infamous Test snap as a debian package!'},
      ),
    ],
  });

  group('autocomplete options', () {
    testWidgets('only snap results', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, searchParameters) =>
                  mockSnapSearchProvider(searchParameters),
            ),
            appstreamSearchProvider.overrideWith(
              (ref, query) => Stream.value([]),
            ),
          ],
          child: SearchField(
            onSearch: (_) {},
            onSnapSelected: (_) {},
            onDebSelected: (_) {},
            searchFocus: FocusNode(),
          ),
        ),
      );

      final testSnapFinder = find.text('Test Snap');
      final anotherTestSnapFinder = find.text('Another Test Snap');
      final searchForQueryFinder = find.text(
        tester.l10n.searchFieldSearchForLabel('testsn'),
      );

      expect(testSnapFinder, findsNothing);
      expect(anotherTestSnapFinder, findsNothing);
      expect(searchForQueryFinder, findsNothing);

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'testsn');
      await tester.pumpAndSettle();

      expect(testSnapFinder, findsOneWidget);
      expect(anotherTestSnapFinder, findsOneWidget);
      expect(searchForQueryFinder, findsOneWidget);

      expect(find.text(tester.l10n.searchFieldSnapSection), findsOneWidget);
      expect(find.text(tester.l10n.searchFieldDebSection), findsNothing);
    });

    testWidgets('snap and deb results', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, searchParameters) =>
                  mockSnapSearchProvider(searchParameters),
            ),
            appstreamSearchProvider.overrideWith(
              (ref, query) => mockDebSearchProvider(query),
            ),
          ],
          child: SearchField(
            onSearch: (_) {},
            onSnapSelected: (_) {},
            onDebSelected: (_) {},
            searchFocus: FocusNode(),
          ),
        ),
      );

      final testSnapFinder = find.text('Test Snap');
      final anotherTestSnapFinder = find.text('Another Test Snap');
      final testDebFinder = find.text('Test Sn..I mean deb');
      final searchForQueryFinder = find.text(
        tester.l10n.searchFieldSearchForLabel('testsn'),
      );

      expect(testSnapFinder, findsNothing);
      expect(anotherTestSnapFinder, findsNothing);
      expect(testDebFinder, findsNothing);
      expect(searchForQueryFinder, findsNothing);

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'testsn');
      await tester.pumpAndSettle();

      expect(testSnapFinder, findsOneWidget);
      expect(testDebFinder, findsOneWidget);
      expect(anotherTestSnapFinder, findsOneWidget);
      expect(searchForQueryFinder, findsOneWidget);

      expect(find.text(tester.l10n.searchFieldSnapSection), findsOneWidget);
      expect(find.text(tester.l10n.searchFieldDebSection), findsOneWidget);
    });
  });

  group('unified options', () {
    final snapSearch = createMockSnapSearchProvider({
      const SnapSearchParameters(query: 'edit'): [
        createSnap(
          name: 'editor',
          title: 'Editor Snap',
          commonIds: ['org.example.Editor'],
        ),
        createSnap(name: 'writer', title: 'Writer Snap'),
      ],
    });
    final debSearch = createMockDebSearchProvider({
      'edit': [
        createAppstreamComponent(id: 'org.example.Notes', name: 'Notes Deb'),
        createAppstreamComponent(id: 'org.example.Editor', name: 'Editor Deb'),
      ],
    });

    Future<void> pumpUnifiedField(
      WidgetTester tester, {
      ValueChanged<String>? onSnapSelected,
      ValueChanged<String>? onDebSelected,
    }) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, searchParameters) => snapSearch(searchParameters),
            ),
            appstreamSearchProvider.overrideWith(
              (ref, query) => debSearch(query),
            ),
          ],
          child: SearchField(
            onSearch: (_) {},
            onSnapSelected: onSnapSelected ?? (_) {},
            onDebSelected: onDebSelected ?? (_) {},
            searchFocus: FocusNode(),
            unifiedResults: true,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'edit');
      await tester.pumpAndSettle();
    }

    testWidgets('lists snaps, then debs without a snap', (tester) async {
      await pumpUnifiedField(tester);

      final tops = [
        for (final title in ['Editor Snap', 'Writer Snap', 'Notes Deb'])
          tester.getTopLeft(find.text(title)).dy,
      ];
      expect(tops, [...tops]..sort());
      expect(find.text('Editor Deb'), findsNothing);
      expect(find.text(tester.l10n.searchFieldSnapSection), findsNothing);
      expect(find.text(tester.l10n.searchFieldDebSection), findsNothing);
      expect(
        find.text(tester.l10n.searchFieldSearchForLabel('edit')),
        findsOneWidget,
      );
    });

    testWidgets('opens the selected app', (tester) async {
      final snaps = <String>[];
      final debs = <String>[];
      await pumpUnifiedField(
        tester,
        onSnapSelected: snaps.add,
        onDebSelected: debs.add,
      );

      await tester.tap(find.text('Notes Deb'));
      await tester.pumpAndSettle();

      expect(debs, ['org.example.Notes']);
      expect(snaps, isEmpty);
    });
  });

  testWidgets('options still load when rebuilt during a slow search', (
    tester,
  ) async {
    final rebuild = ValueNotifier(0);
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          snapSearchProvider.overrideWith((ref, searchParameters) async* {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            yield [createSnap(name: 'testsnap', title: 'Test Snap')];
          }),
          appstreamSearchProvider.overrideWith(
            (ref, query) => Stream.value([]),
          ),
        ],
        child: ValueListenableBuilder<int>(
          valueListenable: rebuild,
          builder: (_, _, _) => SearchField(
            onSearch: (_) {},
            onSnapSelected: (_) {},
            onDebSelected: (_) {},
            searchFocus: FocusNode(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'testsn');
    await tester.pump(const Duration(milliseconds: 150));
    rebuild.value++;
    // Small steps so a frame is built while the search is still running.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Test Snap'), findsOneWidget);
  });

  group('callbacks', () {
    testWidgets('onSelected', (tester) async {
      final mockSearchCallback = MockStringCallback();
      final mockSelectedCallback = MockStringCallback();

      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, searchParameters) =>
                  mockSnapSearchProvider(searchParameters),
            ),
            appstreamSearchProvider.overrideWith(
              (ref, query) => Stream.value([]),
            ),
          ],
          child: SearchField(
            onSearch: mockSearchCallback.call,
            onSnapSelected: mockSelectedCallback.call,
            onDebSelected: (_) {},
            searchFocus: FocusNode(),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'testsn');
      await tester.pumpAndSettle();

      final anotherTestSnapFinder = find.text('Another Test Snap');
      await tester.tap(anotherTestSnapFinder);
      await tester.pumpAndSettle();
      verify(mockSelectedCallback('testsnap2')).called(1);
      verifyNever(mockSearchCallback(any));
    });
    testWidgets('onSearch from dropdown', (tester) async {
      final mockSearchCallback = MockStringCallback();
      final mockSelectedCallback = MockStringCallback();

      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, searchParameters) =>
                  mockSnapSearchProvider(searchParameters),
            ),
            appstreamSearchProvider.overrideWith(
              (ref, query) => Stream.value([]),
            ),
          ],
          child: SearchField(
            onSearch: mockSearchCallback.call,
            onSnapSelected: mockSelectedCallback.call,
            onDebSelected: (_) {},
            searchFocus: FocusNode(),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'testsn');
      await tester.pumpAndSettle();

      final searchForQueryFinder = find.text(
        tester.l10n.searchFieldSearchForLabel('testsn'),
      );
      await tester.tap(searchForQueryFinder);
      await tester.pumpAndSettle();
      verify(mockSearchCallback('testsn')).called(1);
      verifyNever(mockSelectedCallback(any));
    });
    testWidgets('onSearch fallback', (tester) async {
      final mockSearchCallback = MockStringCallback();
      final mockSelectedCallback = MockStringCallback();

      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith(
              (ref, searchParameters) =>
                  mockSnapSearchProvider(searchParameters),
            ),
            appstreamSearchProvider.overrideWith(
              (ref, query) => Stream.value([]),
            ),
          ],
          child: SearchField(
            onSearch: mockSearchCallback.call,
            onSnapSelected: mockSelectedCallback.call,
            onDebSelected: (_) {},
            searchFocus: FocusNode(),
          ),
        ),
      );

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'testsn');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      verify(mockSearchCallback('testsn')).called(1);
      verifyNever(mockSelectedCallback(any));
    });
  });
}
