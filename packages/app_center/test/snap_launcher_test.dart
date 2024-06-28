import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:snapd/snapd.dart';

import 'snap_launcher_test.mocks.dart';
import 'test_utils.dart';

@GenerateMocks([PrivilegedDesktopLauncher])
void main() {
  test('launcher unavailable', () {
    final snap = createSnap(name: '');
    final launcher = MockPrivilegedDesktopLauncher();
    when(launcher.isAvailable).thenReturn(false);

    final snapLaucher = SnapLauncher(snap: snap, launcher: launcher);
    expect(snapLaucher.isLaunchable, isFalse);
  });

  test('desktop snap', () {
    final snap = createSnap(
      name: 'desktopsnap',
      type: 'app',
      apps: [
        const SnapApp(
          snap: 'desktopsnap',
          name: 'desktopsnapapp',
          desktopFile: '/foo/bar/desktopsnapapp.desktop',
        ),
      ],
    );
    final launcher = MockPrivilegedDesktopLauncher();
    when(launcher.isAvailable).thenReturn(true);

    final snapLauncher = SnapLauncher(snap: snap, launcher: launcher);
    expect(snapLauncher.desktopFile, equals('/foo/bar/desktopsnapapp.desktop'));
    expect(snapLauncher.isLaunchable, isTrue);

    snapLauncher.open();
    verify(launcher.openDesktopEntry('desktopsnapapp.desktop')).called(1);
  });

  test('non-desktop snap', () {
    final snap = createSnap(name: 'nondesktopsnap');
    final launcher = MockPrivilegedDesktopLauncher();
    when(launcher.isAvailable).thenReturn(true);

    final snapLauncher = SnapLauncher(snap: snap, launcher: launcher);
    expect(snapLauncher.desktopFile, isNull);
    expect(snapLauncher.isLaunchable, isFalse);
  });
}
