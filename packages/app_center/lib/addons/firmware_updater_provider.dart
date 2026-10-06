import 'package:app_center/constants.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

/// Launcher for the installed firmware updater snap, or `null` when it isn't
/// installed or has no launchable desktop entry.
final firmwareUpdaterLauncherProvider =
    FutureProvider.autoDispose<SnapLauncher?>((ref) async {
      final Snap snap;
      try {
        snap = await getService<SnapdService>().getSnap(
          kFirmwareUpdaterSnapName,
        );
      } on SnapdException catch (e) {
        if (e.kind == 'snap-not-found') return null;
        rethrow;
      }
      final launcher = ref.watch(launchProvider(snap));
      return launcher.isLaunchable ? launcher : null;
    });
