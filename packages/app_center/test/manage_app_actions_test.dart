import 'package:app_center/manage/manage_app_actions.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/snapd/snap_launcher.dart';
import 'package:app_center/snapd/snapd_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

/// [StoreSnap] stub returning a fixed snap, bypassing the snap cache.
class _FixedStoreSnap extends StoreSnap {
  _FixedStoreSnap(this._snap);

  final Snap? _snap;

  @override
  Future<Snap?> build(String snapName) async => _snap;
}

void main() {
  tearDown(resetAllServices);

  testWidgets('renders open and remove buttons for installed snap with apps', (
    tester,
  ) async {
    final snap = createSnap(
      name: 'testsnap',
      title: 'Test Snap',
      type: 'app',
      apps: [const SnapApp(name: 'testsnap')],
    );
    final snapd = registerMockSnapdService(localSnap: snap);
    registerMockRatingsService();

    final mockLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [launchProvider(snap).overrideWithValue(mockLauncher)],
        child: ManageAppActions(app: ManageAppData.snap(snap: snap)),
      ),
    );
    await tester.pump();

    expect(find.text(tester.l10n.snapActionOpenLabel), findsOneWidget);
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsOneWidget);

    // Tap open: goes straight to the launcher, no SnapModel involved.
    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    await tester.pump();
    verify(mockLauncher.open()).called(1);

    // Tap remove: the SnapModel is built lazily on action, then remove runs.
    await tester.tap(find.text(tester.l10n.snapActionRemoveLabel));
    await tester.pumpAndSettle();
    verify(snapd.remove('testsnap')).called(1);
  });

  testWidgets('hides open button for non-launchable snap', (tester) async {
    final snap = createSnap(
      name: 'testsnap',
      title: 'Test Snap',
      type: 'app',
      apps: [const SnapApp(name: 'testsnap')],
    );
    registerMockSnapdService(localSnap: snap);
    registerMockRatingsService();

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider(
            snap,
          ).overrideWithValue(createMockSnapLauncher()),
        ],
        child: ManageAppActions(app: ManageAppData.snap(snap: snap)),
      ),
    );
    await tester.pump();

    expect(find.text(tester.l10n.snapActionOpenLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsOneWidget);
  });

  testWidgets('renders update button when showOnlyUpdate is true', (
    tester,
  ) async {
    final snap = createSnap(
      name: 'testsnap',
      title: 'Test Snap',
      version: '1.0',
      trackingChannel: 'latest/stable',
    );
    final storeSnap = createSnap(
      name: 'testsnap',
      version: '2.0',
      channels: {
        'latest/stable': SnapChannel(releasedAt: DateTime(2026)),
      },
    );
    final snapd = registerMockSnapdService(localSnap: snap);
    registerMockRatingsService();

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider(
            snap,
          ).overrideWithValue(createMockSnapLauncher(isLaunchable: true)),
          storeSnapProvider(
            'testsnap',
          ).overrideWith(() => _FixedStoreSnap(storeSnap)),
        ],
        child: ManageAppActions(
          app: ManageAppData.snap(snap: snap, updateVersion: '2.0'),
          showOnlyUpdate: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text(tester.l10n.snapActionUpdateLabel), findsOneWidget);
    expect(find.text(tester.l10n.snapActionOpenLabel), findsNothing);

    // The SnapModel is built lazily on action; update is guarded on the
    // store snap being available.
    await tester.tap(find.text(tester.l10n.snapActionUpdateLabel));
    await tester.pumpAndSettle();
    verify(
      snapd.refresh(
        'testsnap',
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    ).called(1);
  });

  testWidgets('shows active change status for in-progress change', (
    tester,
  ) async {
    final snap = createSnap(name: 'testsnap', title: 'Test Snap', type: 'app');
    registerMockSnapdService(
      localSnap: snap,
      changes: [
        SnapdChange(id: '1', spawnTime: DateTime(2026)),
      ],
    );
    registerMockRatingsService();

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider(
            snap,
          ).overrideWithValue(createMockSnapLauncher(isLaunchable: true)),
        ],
        child: ManageAppActions(app: ManageAppData.snap(snap: snap)),
      ),
    );
    await tester.pumpAndSettle();

    // Progress UI with a cancel button instead of the action buttons,
    // seeded from the change that was already in progress.
    expect(find.text(tester.l10n.snapActionCancelLabel), findsOneWidget);
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionOpenLabel), findsNothing);
  });
}
