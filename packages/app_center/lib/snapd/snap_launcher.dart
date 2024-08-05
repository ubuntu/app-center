import 'package:app_center/constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final launchProvider =
    Provider.family.autoDispose<SnapLauncher, Snap>((ref, snap) {
  final launcher = getService<PrivilegedDesktopLauncher>();
  return SnapLauncher(snap: snap, launcher: launcher);
});

class SnapLauncher {
  const SnapLauncher({required this.snap, required this.launcher});

  final Snap snap;
  final PrivilegedDesktopLauncher launcher;

  String? get desktopFile =>
      snap.apps.firstWhereOrNull((app) => app.desktopFile != null)?.desktopFile;
  bool get isLaunchable =>
      snap.type == 'app' &&
      desktopFile != null &&
      launcher.isAvailable &&
      snap.name != kSnapName;

  void open() => launcher.openDesktopEntry(basename(desktopFile!));
}
