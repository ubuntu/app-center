import 'package:app_center/appstream.dart';
import 'package:app_center/search.dart';
import 'package:app_center/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

abstract class StringCallback {
  void call(String? arg) {}
}

class MockStringCallback extends Mock implements StringCallback {}

void main() {
  final mockSnapSearchProvider = createMockSnapSearchProvider({
    const SnapSearchParameters(query: 'testsn'): const [
      Snap(name: 'testsnap', title: 'Test Snap'),
      Snap(name: 'testsnap2', title: 'Another Test Snap'),
    ]
  });

  final mockDebSearchProvider = createMockDebSearchProvider({
    'testsn': const [
      AppstreamComponent(
        id: 'testsnImeanDeb.desktop',
        type: AppstreamComponentType.desktopApplication,
        package: 'testsn',
        name: {'C': 'Test Sn..I mean deb'},
        summary: {'C': 'The infamous Test snap as a debian package!'},
      )
    ]
  });

  group('autocomplete options', () {
    testWidgets('only snap results', (tester) async {
      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith((ref, searchParameters) =>
                mockSnapSearchProvider(searchParameters)),
            appstreamSearchProvider
                .overrideWith((ref, query) => Stream.value([]))
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
      final searchForQueryFinder =
          find.text(tester.l10n.searchFieldSearchForLabel('testsn'));

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
            snapSearchProvider.overrideWith((ref, searchParameters) =>
                mockSnapSearchProvider(searchParameters)),
            appstreamSearchProvider
                .overrideWith((ref, query) => mockDebSearchProvider(query))
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
      final searchForQueryFinder =
          find.text(tester.l10n.searchFieldSearchForLabel('testsn'));

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

  group('callbacks', () {
    testWidgets('onSelected', (tester) async {
      final mockSearchCallback = MockStringCallback();
      final mockSelectedCallback = MockStringCallback();

      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            snapSearchProvider.overrideWith((ref, searchParameters) =>
                mockSnapSearchProvider(searchParameters)),
            appstreamSearchProvider
                .overrideWith((ref, query) => Stream.value([]))
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
            snapSearchProvider.overrideWith((ref, searchParameters) =>
                mockSnapSearchProvider(searchParameters)),
            appstreamSearchProvider
                .overrideWith((ref, query) => Stream.value([]))
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

      final searchForQueryFinder =
          find.text(tester.l10n.searchFieldSearchForLabel('testsn'));
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
            snapSearchProvider.overrideWith((ref, searchParameters) =>
                mockSnapSearchProvider(searchParameters)),
            appstreamSearchProvider
                .overrideWith((ref, query) => Stream.value([]))
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
