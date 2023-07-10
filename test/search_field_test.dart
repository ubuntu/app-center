import 'package:app_store/search.dart';
import 'package:app_store/src/search/search_provider.dart';
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
  final mockSearchProvider = createMockSearchProvider({
    'testsnap': const [
      Snap(name: 'testsnap', title: 'Test Snap'),
      Snap(name: 'testsnap2', title: 'Another Test Snap'),
    ]
  });

  testWidgets('autocomplete options', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          searchProvider.overrideWith((ref, query) => mockSearchProvider(query))
        ],
        child: SearchField(onSearch: (_) {}, onSelected: (_) {}),
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
  });

  group('callbacks', () {
    testWidgets('onSelected', (tester) async {
      final mockSearchCallback = MockStringCallback();
      final mockSelectedCallback = MockStringCallback();

      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            searchProvider
                .overrideWith((ref, query) => mockSearchProvider(query))
          ],
          child: SearchField(
            onSearch: mockSearchCallback,
            onSelected: mockSelectedCallback,
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
    testWidgets('onSearch', (tester) async {
      final mockSearchCallback = MockStringCallback();
      final mockSelectedCallback = MockStringCallback();

      await tester.pumpApp(
        (_) => ProviderScope(
          overrides: [
            searchProvider
                .overrideWith((ref, query) => mockSearchProvider(query))
          ],
          child: SearchField(
            onSearch: mockSearchCallback,
            onSelected: mockSelectedCallback,
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
  });
}
