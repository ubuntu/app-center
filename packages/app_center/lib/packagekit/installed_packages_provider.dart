import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'installed_packages_provider.g.dart';

/// Returns all installed packages from PackageKit.
@riverpod
Future<List<PackageKitPackageEvent>> installedPackages(Ref ref) async {
  final packageKit = getService<PackageKitService>();
  await packageKit.activateService();
  if (!packageKit.isAvailable) return [];
  return packageKit.getInstalledPackages();
}

/// Returns a map of package name -> update package ID.
@riverpod
Future<Map<String, PackageKitPackageId>> debsWithUpdates(Ref ref) async {
  final packageKit = getService<PackageKitService>();
  await packageKit.activateService();
  if (!packageKit.isAvailable) return {};
  final updates = await packageKit.getUpdates();
  return {for (final u in updates) u.packageId.name: u.packageId};
}
