import 'package:app_center/constants.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/manage.dart';
import 'package:app_center/manage/manage_snap_tile.dart';
import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_test/yaru_test.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

void main() {
  final nonRefreshableSnaps = [
    createSnap(
      name: 'testsnap',
      title: 'Test Snap',
      version: '1.0',
      channel: 'latest/stable',
    ),
    createSnap(
      name: 'testsnap2',
      title: 'Another Test Snap',
      version: '1.5',
      channel: 'latest/candidate',
    ),
  ];
  final refreshableSnaps = [
    createSnap(
      name: 'testsnap3',
      title: 'Snap with an update',
      version: '2.0',
      channel: 'latest/stable',
      channels: {
        'latest/stable': SnapChannel(
          confinement: SnapConfinement.strict,
          size: 1337,
          releasedAt: DateTime(1970),
          version: '1.0',
        ),
        'latest/edge': SnapChannel(
          confinement: SnapConfinement.classic,
          size: 31337,
          releasedAt: DateTime(1970, 1, 2),
          version: '2.0',
        ),
      },
    ),
  ];

  final refreshableAppCenter = createSnap(
    name: kSnapName,
    title: 'App Center with an update',
    version: '2.0',
    channel: 'latest/stable',
    channels: {
      'latest/stable': SnapChannel(
        confinement: SnapConfinement.strict,
        size: 1337,
        releasedAt: DateTime(1970),
        version: '1.0',
      ),
      'latest/edge': SnapChannel(
        confinement: SnapConfinement.classic,
        size: 31337,
        releasedAt: DateTime(1970, 1, 2),
        version: '2.0',
      ),
    },
    refreshInhibit: RefreshInhibit(proceedTime: DateTime(1970)),
  );

  final refreshableOpenApp = createSnap(
    name: 'flame',
    title: 'The Flutter game engine',
    version: '2.0',
    channel: 'latest/stable',
    channels: {
      'latest/stable': SnapChannel(
        confinement: SnapConfinement.strict,
        size: 1337,
        releasedAt: DateTime(1970),
        version: '1.0',
      ),
      'latest/edge': SnapChannel(
        confinement: SnapConfinement.classic,
        size: 31337,
        releasedAt: DateTime(1970, 1, 2),
        version: '2.0',
      ),
    },
    refreshInhibit: RefreshInhibit(proceedTime: DateTime(1970)),
  );

  final snapData = SnapData(
    name: refreshableSnaps[0].name,
    localSnap: refreshableSnaps[0],
    storeSnap: refreshableSnaps[0],
  );

  late MockSnapdService snapd;
  setUp(() {
    snapd = registerMockSnapdService(
      localSnap: snapData.localSnap,
      storeSnap: snapData.storeSnap,
      installedSnaps: nonRefreshableSnaps + refreshableSnaps,
      refreshableSnaps: refreshableSnaps,
      changes: [],
    );
  });
  tearDown(resetAllServices);

  testWidgets('list installed snaps', (tester) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
        child: const ManagePage(),
      ),
    );

    await tester.pumpAndSettle();
    final testTile = find.snapTile('Test Snap');
    expect(testTile, findsOneWidget);
    expect(
      find.descendant(of: testTile, matching: find.text('1.0')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: testTile, matching: find.text('latest/stable')),
      findsOneWidget,
    );

    final testTile2 = find.snapTile('Another Test Snap');
    expect(testTile2, findsOneWidget);
    expect(
      find.descendant(of: testTile2, matching: find.text('1.5')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: testTile2, matching: find.text('latest/candidate')),
      findsOneWidget,
    );
  });

  testWidgets('launch desktop snap', (tester) async {
    await resetAllServices();
    registerMockSnapdService(
      installedSnaps: nonRefreshableSnaps,
    );

    final snapLauncher = createMockSnapLauncher(isLaunchable: true);
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith(
            (_, snap) => switch (snap.name) {
              'testsnap' => snapLauncher,
              _ => createMockSnapLauncher(),
            },
          ),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
        child: const ManagePage(),
      ),
    );
    await tester.pump();

    final testTile = find.snapTile('Test Snap');
    final testTile2 = find.snapTile('Another Test Snap');
    expect(testTile, findsOneWidget);

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
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
        child: const ManagePage(),
      ),
    );
    await tester.pumpAndSettle();

    final testTile = find.snapTile('Snap with an update');
    expect(testTile, findsOneWidget);
    expect(
      find.descendant(of: testTile, matching: find.text('2.0')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: testTile, matching: find.text('latest/stable')),
      findsOneWidget,
    );

    await tester.tap(find.text(tester.l10n.managePageUpdateAllLabel));
    verify(
      snapd.refresh(
        refreshableSnaps.first.name,
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    ).called(1);
  });

  testWidgets('refresh individual snap', (tester) async {
    final container = createContainer(
      overrides: [
        launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
        showLocalSystemAppsProvider.overrideWith((ref) => true),
      ],
    );

    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: const ManagePage(),
      ),
    );
    await container.read(snapModelProvider(snapData.name).future);
    await tester.pumpAndSettle();

    final testTile = find.snapTile('Snap with an update');
    expect(testTile, findsOneWidget);
    expect(
      find.descendant(of: testTile, matching: find.text('2.0')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: testTile, matching: find.text('latest/stable')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();

    verifyNever(snapd.refresh(any));
    await tester.tap(find.text(tester.l10n.snapActionUpdateLabel));
    verify(snapd.refresh(any, channel: anyNamed('channel'))).called(1);
  });

  testWidgets('refreshing all', (tester) async {
    final mockChange = SnapdChange(
      id: '1234',
      spawnTime: DateTime(1970),
      kind: 'refresh-snap',
      tasks: [
        const SnapdTask(id: '', progress: SnapdTaskProgress(done: 1, total: 4)),
      ],
    );

    final snapName = refreshableSnaps.first.name;
    when(snapd.getChanges(name: snapName))
        .thenAnswer((_) async => [mockChange]);

    final container = createContainer(
      overrides: [
        launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
        showLocalSystemAppsProvider.overrideWith((ref) => true),
        activeChangeProvider.overrideWith((_, __) => mockChange),
        currentlyRefreshAllSnapsProvider.overrideWith((_) => [snapName]),
      ],
    );

    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: const ManagePage(),
      ),
    );
    await container.read(snapModelProvider(snapData.name).future);
    await tester.pump();

    final refreshButton =
        find.buttonWithText(tester.l10n.snapActionUpdatingLabel);
    expect(refreshButton, findsExactly(2));
    expect(refreshButton, isDisabled);

    final testTile = find.snapTile('Snap with an update');
    expect(testTile, findsOneWidget);
    final activeChangeStatus = find.byType(ActiveChangeStatus);
    expect(activeChangeStatus, findsOneWidget);
    final progressIndicator = find.descendant(
      of: testTile,
      matching: find.byType(YaruCircularProgressIndicator),
    );
    expect(progressIndicator, findsOneWidget);
    expect(
      tester.widget<YaruCircularProgressIndicator>(progressIndicator).value,
      equals(0.25),
    );
  });

  testWidgets('cancel refresh all', (tester) async {
    final mockChange = SnapdChange(id: '', spawnTime: DateTime(1970));

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
          activeChangeProvider.overrideWith((_, __) => mockChange),
          currentlyRefreshAllSnapsProvider.overrideWith((_) => ['name']),
        ],
        child: const ManagePage(),
      ),
    );
    await tester.pumpAndSettle();

    final cancelButton = find.buttonWithText(tester.l10n.snapActionCancelLabel);
    expect(cancelButton, findsOneWidget);
    expect(cancelButton, isEnabled);
  });

  testWidgets('show app center update available', (tester) async {
    await resetAllServices();
    registerMockSnapdService(
      localSnap: refreshableAppCenter,
      storeSnap: refreshableAppCenter,
      installedSnaps: [refreshableAppCenter],
      refreshableSnaps: [refreshableAppCenter],
    );

    final container = createContainer(
      overrides: [
        launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
        showLocalSystemAppsProvider.overrideWith((ref) => true),
      ],
    );

    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: const ManagePage(),
      ),
    );
    await tester.pump();

    final infoBox = find.widgetWithText(
      YaruInfoBox,
      tester.l10n.managePageOwnUpdateAvailable,
    );
    expect(infoBox, findsOneWidget);
  });

  testWidgets(
    'show quit to refresh label when update is available for open app',
    (tester) async {
      await resetAllServices();
      registerMockSnapdService(
        localSnap: refreshableOpenApp,
        storeSnap: refreshableOpenApp,
        installedSnaps: [refreshableOpenApp],
        refreshableSnaps: [refreshableOpenApp],
      );

      final container = createContainer(
        overrides: [
          launchProvider.overrideWith((_, __) => createMockSnapLauncher()),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
      );

      await tester.pumpApp(
        (_) => UncontrolledProviderScope(
          container: container,
          child: const ManagePage(),
        ),
      );
      await tester.pumpAndSettle();

      final quitToUpdateNotice = find.widgetWithText(
        QuitToUpdateNotice,
        tester.l10n.managePageQuitToUpdate,
      );
      expect(quitToUpdateNotice, findsOneWidget);
    },
  );

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
