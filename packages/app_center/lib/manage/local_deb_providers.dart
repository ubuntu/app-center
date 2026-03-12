import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:appstream/appstream.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_providers.g.dart';

@Riverpod(keepAlive: true)
class InstalledDebs extends _$InstalledDebs {
  @override
  Future<List<ManageDebData>> build() async {
    final packageKit = getService<PackageKitService>();
    final appstream = getService<AppstreamService>();

    await packageKit.activateService();
    await appstream.init();

    // Get Appstream components with package names
    final appstreamPackages = <String, AppstreamComponent>{};
    for (final component in appstream.components) {
      final packageName = component.package;
      if (packageName != null && packageName.isNotEmpty) {
        appstreamPackages[packageName] = component;
      }
    }

    // Batch resolve all Appstream package names in one transaction
    final resolvedPackages = await packageKit.resolve(
      appstreamPackages.keys.toList(),
      installedOnly: true,
    );

    // Get package IDs for installed packages to fetch details
    final installedPackageIds = resolvedPackages.values
        .whereType<PackageKitPackageInfo>()
        .map((p) => p.packageId)
        .toList();

    // Fetch details (including size) for all installed packages
    final packageDetails = await packageKit.getDetailsMany(installedPackageIds);

    // Build list of installed debs
    final debs = <ManageDebData>[];
    for (final entry in appstreamPackages.entries) {
      final packageInfo = resolvedPackages[entry.key];
      if (packageInfo != null) {
        final details = packageDetails[entry.key];
        debs.add(
          ManageDebData(
            component: entry.value,
            packageInfo: packageInfo,
            size: details?.size,
          ),
        );
      }
    }

    return debs;
  }

  /// Used to remove a deb from the list without reloading the whole provider.
  /// Should be used when a deb is uninstalled directly from the manage page.
  void removeFromList(String debId) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.where((d) => d.id != debId).toList(),
    );
  }
}
