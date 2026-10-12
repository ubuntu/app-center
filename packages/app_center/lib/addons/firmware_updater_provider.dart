import 'package:app_center/constants.dart';
import 'package:app_center/snapd/snap_details_backend.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firmware_updater_provider.g.dart';

/// Launcher for the installed firmware updater snap, or `null` when it isn't
/// installed or has no launchable desktop entry.
@riverpod
Future<SnapLauncher?> firmwareUpdaterLauncher(Ref ref) async {
  final snap = await ref.watch(
    snapLocalStateProvider(kFirmwareUpdaterSnapName).future,
  );
  if (snap == null) return null;
  final launcher = ref.watch(launchProvider(snap));
  return launcher.isLaunchable ? launcher : null;
}
