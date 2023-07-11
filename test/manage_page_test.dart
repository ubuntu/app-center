import 'package:app_store/manage.dart';
import 'package:app_store/src/manage/manage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'manage_page_test.mocks.dart';
import 'test_utils.dart';

@GenerateMocks([PrivilegedDesktopLauncher])
void main() {
  const mockManageProvider = [
    Snap(
        name: 'testsnap',
        title: 'Test Snap',
        version: '1.0',
        channel: 'latest/stable',
        type: 'app',
        apps: [
          SnapApp(
            snap: 'testsnap',
            name: 'testsnapapp',
            desktopFile: '/foo/bar/testsnapapp.desktop',
          )
        ]),
    Snap(
      name: 'testsnap2',
      title: 'Another Test Snap',
      version: '1.5',
      channel: 'latest/candidate',
    ),
  ];
  testWidgets('list installed snaps', (tester) async {
    final mockLauncher = MockPrivilegedDesktopLauncher();
    when(mockLauncher.isAvailable).thenReturn(true);
    registerMockService<PrivilegedDesktopLauncher>(mockLauncher);

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          manageProvider.overrideWith((_) => mockManageProvider),
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
    final mockLauncher = MockPrivilegedDesktopLauncher();
    when(mockLauncher.isAvailable).thenReturn(true);
    registerMockService<PrivilegedDesktopLauncher>(mockLauncher);

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          manageProvider.overrideWith((_) => mockManageProvider),
        ],
        child: const ManagePage(),
      ),
    );

    await tester.pumpAndSettle();

    final testTile = find.snapTile('Test Snap');
    final testTile2 = find.snapTile('Another Test Snap');

    final openButton = find.descendant(
      of: testTile,
      matching: find.buttonWithText(tester.l10n.managePageOpenLabel),
    );
    final openButton2 = find.descendant(
      of: testTile2,
      matching: find.buttonWithText(tester.l10n.managePageOpenLabel),
    );

    expect(openButton, findsOneWidget);
    expect(openButton2, findsNothing);

    expect(tester.widget<ButtonStyleButton>(openButton).enabled, isTrue);

    await tester.tap(openButton);
    verify(mockLauncher.openDesktopEntry('testsnapapp.desktop')).called(1);
  });
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
