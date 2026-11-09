import 'package:app_center/apps/uninstall_dependents_dialog.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/providers/uninstall_check_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

/// Sorted names of the other packages that removing [packageIds] would also
/// remove, without removing anything.
Future<List<String>> packageKitRemovalDependents(
  Iterable<PackageKitPackageId> packageIds,
) async {
  final packageKit = getService<PackageKitService>();
  await packageKit.activateService();
  final dependents = await packageKit.simulateRemove(packageIds);
  return {for (final p in dependents) p.packageId.name}.toList()..sort();
}

/// Asks the user to confirm removing [packageIds] when doing so would also
/// remove other packages. Returns whether the removal should go ahead.
///
/// If the removal cannot be simulated, the error is reported to the user and
/// the removal does not go ahead. Only one check runs at a time (see
/// [uninstallCheckProvider]); others return false.
Future<bool> confirmPackageKitRemoval(
  BuildContext context, {
  required String appName,
  required Iterable<PackageKitPackageId> packageIds,
}) async {
  final check = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(uninstallCheckProvider.notifier);
  if (!check.begin()) return false;
  try {
    final List<String> dependents;
    try {
      dependents = await packageKitRemovalDependents(packageIds);
    } on Exception catch (error) {
      getService<ErrorStreamController>().add(error);
      return false;
    }
    if (dependents.isEmpty) return true;
    if (!context.mounted) return false;
    return await confirmUninstallWithDependents(
      context,
      appName: appName,
      dependents: dependents,
    );
  } finally {
    check.end();
  }
}
