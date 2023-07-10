import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';
import '/snapx.dart';

final manageProvider = FutureProvider.autoDispose((ref) async {
  final snaps = await getService<SnapdService>().getSnaps();
  snaps.sort(((a, b) =>
      a.titleOrName.toLowerCase().compareTo(b.titleOrName.toLowerCase())));
  return snaps;
});

final launcherProvider = FutureProvider((ref) async {
  final launcher = PrivilegedDesktopLauncher();
  await launcher.connect();
  ref.onDispose(launcher.close);
  return launcher;
});

final launchProvider =
    FutureProvider.family.autoDispose((ref, Snap snap) async {
  final launcher = await ref.watch(launcherProvider.future);
  return SnapLauncher(snap: snap, launcher: launcher);
});

class SnapLauncher {
  const SnapLauncher({required this.snap, required this.launcher});

  final Snap snap;
  final PrivilegedDesktopLauncher launcher;

  String? get desktopFile =>
      snap.apps.firstWhereOrNull((app) => app.desktopFile != null)?.desktopFile;
  bool get isLaunchable =>
      snap.type == 'app' && desktopFile != null && launcher.isAvailable;

  void _open() => launcher.openDesktopEntry(basename(desktopFile!));
  void Function()? get open => isLaunchable ? _open : null;
}
