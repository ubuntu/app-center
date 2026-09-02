import 'package:app_center/manage/manage_app_actions.dart';
import 'package:app_center/snapd/snap_launcher.dart';
import 'package:app_center/snapd/snap_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

void main() {
  late MockSnapdService snapd;

  setUp(() {
    snapd = registerMockSnapdService();
    registerMockRatingsService();
  });

  tearDown(resetAllServices);

  testWidgets('renders open and remove buttons for installed snap with apps', (
    tester,
  ) async {
    final snap = createSnap(
      name: 'testsnap',
      title: 'Test Snap',
      apps: [const SnapApp(name: 'testsnap')],
    );

    final mockLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider(snap).overrideWithValue(mockLauncher),
        ],
        child: ManageAppActions(snap: snap),
      ),
    );
    await tester.pump();

    expect(find.text(tester.l10n.snapActionOpenLabel), findsOneWidget);
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsOneWidget);

    // Tap open
    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    await tester.pump();
    verify(mockLauncher.open()).called(1);

    // Tap remove
    await tester.tap(find.text(tester.l10n.snapActionRemoveLabel));
    await tester.pump();
    verify(snapd.remove('testsnap')).called(1);
  });

  testWidgets('renders update button when showOnlyUpdate is true', (
    tester,
  ) async {
    final snap = createSnap(
      name: 'testsnap',
      title: 'Test Snap',
      version: '1.0',
    );

    await tester.pumpApp(
      (_) => ProviderScope(
        child: ManageAppActions(
          snap: snap,
          updateVersion: '2.0',
          showOnlyUpdate: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text(tester.l10n.snapActionUpdateLabel), findsOneWidget);
    expect(find.text(tester.l10n.snapActionOpenLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.snapActionUpdateLabel));
    await tester.pump();
    verify(snapd.refresh('testsnap', channel: anyNamed('channel'), classic: anyNamed('classic'))).called(1);
  });
}
