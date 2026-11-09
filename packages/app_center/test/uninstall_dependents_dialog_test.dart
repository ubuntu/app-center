import 'package:app_center/apps/uninstall_dependents_dialog.dart';
import 'package:app_center/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Future<bool>> open(
    WidgetTester tester,
    List<String> dependents,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final result = confirmUninstallWithDependents(
      context,
      appName: 'Remmina',
      dependents: dependents,
    );
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('lists every dependent and confirms', (tester) async {
    final result = await open(tester, ['plugin-a', 'plugin-b']);

    expect(find.text('plugin-a'), findsOneWidget);
    expect(find.text('plugin-b'), findsOneWidget);

    await tester.tap(find.text('Uninstall'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('cancel declines', (tester) async {
    final result = await open(tester, ['plugin-a']);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('shows a scrollbar only when the list overflows', (tester) async {
    var result = await open(tester, ['plugin-a', 'plugin-b']);
    expect(
      tester.widget<Scrollbar>(find.byType(Scrollbar)).thumbVisibility,
      false,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await result;

    result = await open(tester, [
      for (var i = 0; i < 20; i++) 'package-$i',
    ]);
    expect(
      tester.widget<Scrollbar>(find.byType(Scrollbar)).thumbVisibility,
      true,
    );

    // The first row beyond the visible ones is only partly in view.
    final list = tester.getRect(find.byType(ListView));
    final cutOff = tester.getRect(find.text('package-6'));
    expect(cutOff.top, lessThan(list.bottom));
    expect(cutOff.bottom, greaterThan(list.bottom));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await result;
  });

  testWidgets('package names are selectable', (tester) async {
    final result = await open(tester, ['plugin-a']);

    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(SelectionArea),
      ),
      findsNothing,
    );
    expect(
      find.ancestor(
        of: find.byType(ListView),
        matching: find.byType(SelectionArea),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await result;
  });

  testWidgets('scrolls a long list', (tester) async {
    final result = await open(tester, [
      for (var i = 0; i < 100; i++) 'package-$i',
    ]);

    expect(find.text('package-99'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('package-99'),
      100,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('package-99'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });
}
