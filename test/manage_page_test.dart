import 'package:app_center/manage.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/manage/local_snap_providers.dart';
import 'package:app_center/src/manage/manage_model.dart';
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
  const refreshableSnaps = [
    Snap(
      name: 'testsnap3',
      title: 'Snap with an update',
      version: '2.0',
      channel: 'latest/stable',
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
          showLocalSystemAppsProvider.overrideWith((ref) => true),
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
          showLocalSystemAppsProvider.overrideWith((ref) => true),
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

  testWidgets('refresh snaps', (tester) async {
    final mockUpdatesModel = createMockUpdatesModel(
        refreshableSnapNames: refreshableSnaps.map((snap) => snap.name));
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
          manageModelProvider.overrideWith(
            (_) => createMockManageModel(
              refreshableSnaps: refreshableSnaps,
            ),
          ),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          updatesModelProvider.overrideWith((_) => mockUpdatesModel)
        ],
        child: const ManagePage(),
      ),
    );

    final testTile = find.snapTile('Snap with an update');
    expect(testTile, findsOneWidget);
    expect(find.descendant(of: testTile, matching: find.text('2.0')),
        findsOneWidget);
    expect(find.descendant(of: testTile, matching: find.text('latest/stable')),
        findsOneWidget);

    await tester.tap(find.text(tester.l10n.managePageUpdateAllLabel));
    verify(mockUpdatesModel.updateAll()).called(1);
  });

  testWidgets('error dialog', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
          manageModelProvider.overrideWith(
            (_) => createMockManageModel(
              refreshableSnaps: refreshableSnaps,
            ),
          ),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          updatesModelProvider.overrideWith(
            (_) => createMockUpdatesModel(
              refreshableSnapNames: refreshableSnaps.map((snap) => snap.name),
              errorStream: Stream.value(
                SnapdException(
                  message: 'error message',
                  kind: 'error kind',
                ),
              ),
            ),
          )
        ],
        child: const ManagePage(),
      ),
    );
    await tester.pump();

    expect(find.text('error message'), findsOneWidget);
    expect(find.text('error kind'), findsOneWidget);
  });

  // TODO: test loading states with snap change in progress
  // TODO: test sorting and filtering
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
