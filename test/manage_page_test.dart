import 'package:app_store/manage.dart';
import 'package:app_store/snapd.dart';
import 'package:app_store/src/manage/manage_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  const nonRefreshableSnaps = [
    Snap(
      name: 'testsnap',
      title: 'Test Snap',
      version: '1.0',
      channel: 'latest/stable',
    ),
    Snap(
      name: 'testsnap2',
      title: 'Another Test Snap',
      version: '1.5',
      channel: 'latest/candidate',
    ),
  ];
  testWidgets('list installed snaps', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
          manageModelProvider.overrideWith(
            (_) =>
                createMockManageModel(nonRefreshableSnaps: nonRefreshableSnaps),
          ),
          updatesModelProvider.overrideWith((_) => createMockUpdatesModel())
        ],
        child: const ManagePage(),
      ),
    );

    final testTile = find.snapTile('Test Snap');
    expect(testTile, findsOneWidget);
    expect(find.descendant(of: testTile, matching: find.text('1.0')),
        findsOneWidget);
    expect(find.descendant(of: testTile, matching: find.text('latest/stable')),
        findsOneWidget);

    final testTile2 = find.snapTile('Another Test Snap');
    expect(testTile2, findsOneWidget);
    expect(find.descendant(of: testTile2, matching: find.text('1.5')),
        findsOneWidget);
    expect(
        find.descendant(of: testTile2, matching: find.text('latest/candidate')),
        findsOneWidget);
  });

  testWidgets('launch desktop snap', (tester) async {
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((_, snap) => switch (snap.name) {
                'testsnap' => snapLauncher,
                _ => createMockSnapLauncher(),
              }),
          manageModelProvider.overrideWith((_) => createMockManageModel(
                nonRefreshableSnaps: nonRefreshableSnaps,
              )),
          updatesModelProvider.overrideWith((_) => createMockUpdatesModel())
        ],
        child: const ManagePage(),
      ),
    );

    await tester.pumpAndSettle();

    final testTile = find.snapTile('Test Snap');
    final testTile2 = find.snapTile('Another Test Snap');

    final openButton = find
        .descendant(
          of: testTile,
          matching: find.buttonWithText(tester.l10n.snapActionOpenLabel),
        )
        .hitTestable();
    final openButton2 = find
        .descendant(
          of: testTile2,
          matching: find.buttonWithText(tester.l10n.snapActionOpenLabel),
        )
        .hitTestable();

    expect(openButton, findsOneWidget);
    expect(openButton2, findsNothing);

    expect(tester.widget<ButtonStyleButton>(openButton).enabled, isTrue);

    await tester.tap(openButton);
    verify(snapLauncher.open()).called(1);
  });

  // TODO: test loading states with snap change in progress
}

extension on CommonFinders {
  Finder snapTile(String title) => ancestor(
        of: text(title),
        matching: byType(ListTile),
      );
  Finder buttonWithText(String text) => ancestor(
        of: this.text(text),
        matching: byWidgetPredicate((widget) => widget is ButtonStyleButton),
      );
}
