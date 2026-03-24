import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_providers.freezed.dart';
part 'local_deb_providers.g.dart';

/// Information about a locally installed deb package.
///
/// This local representation batches data fetching for all installed debs,
/// avoiding the per-package API calls that the deb model would require.
///
/// Combines data from multiple sources:
/// - [component]: Appstream metadata (name, icon, description)
/// - [packageInfo]: PackageKit package info (version, architecture)
/// - [details]: PackageKit details (size, description) - fetched separately
/// - [updateVersion]: Available update version, if any
/// - [activeTransactionId]: Tracks ongoing install/remove/update operations
@freezed
class LocalDebInfo with _$LocalDebInfo {
  factory LocalDebInfo({
    required String id,
    required PackageKitPackageEvent packageInfo,
    AppstreamComponent? component,
    PackageKitPackageId? updatePackageId,
    PackageKitDetailsEvent? details,
    int? activeTransactionId,
  }) = _LocalDebInfo;

  const LocalDebInfo._();

  bool get hasUpdate => updatePackageId != null;
  String? get updateVersion => updatePackageId?.version;

  /// Whether this deb has an Appstream entry (user-facing app vs system package).
  bool get hasAppstreamEntry => component != null;

  /// Returns the release date for the currently installed version from
  /// AppStream metadata, or the most recent release date if no exact match.
  DateTime? get releaseDate {
    final installedVersion = packageInfo.packageId.version;
    // Try to find exact version match
    final matchingRelease = component?.releases
        .firstWhereOrNull((r) => r.version == installedVersion);
    if (matchingRelease?.date != null) {
      return matchingRelease!.date;
    }
    // Fall back to most recent release date
    return component?.releases
        .map((r) => r.date)
        .whereType<DateTime>()
        .maxOrNull;
  }
}

final localDebFilterProvider = StateProvider.autoDispose<String>((_) => '');
final showLocalSystemDebsProvider = StateProvider<bool>((_) => false);

/// Returns all installed packages from PackageKit.
@riverpod
Future<List<PackageKitPackageEvent>> installedPackages(Ref ref) async {
  final packageKit = getService<PackageKitService>();
  await packageKit.activateService();
  return packageKit.getInstalledPackages();
}

/// Returns a map of package name -> Appstream component.
@riverpod
Future<Map<String, AppstreamComponent>> componentsByPackage(Ref ref) async {
  final appstream = getService<AppstreamService>();
  await appstream.init();
  return appstream.getComponentsByPackage();
}

/// Returns a map of package name -> update package ID.
@riverpod
Future<Map<String, PackageKitPackageId>> debsWithUpdates(Ref ref) async {
  final packageKit = getService<PackageKitService>();
  await packageKit.activateService();
  final updates = await packageKit.getUpdates();
  return {for (final u in updates) u.packageId.name: u.packageId};
}

/// Fetches detailed package information (size, description, etc.).
@riverpod
Future<Map<String, PackageKitDetailsEvent>> packageDetails(
  Ref ref,
  List<PackageKitPackageId> packageIds,
) async {
  if (packageIds.isEmpty) return {};
  final packageKit = getService<PackageKitService>();
  return packageKit.getDetails(packageIds);
}

/// Aggregates installed deb packages, filtered to only those with Appstream entries.
///
/// Combines data from:
/// 1. [installedPackagesProvider] - all installed packages
/// 2. [componentsByPackageProvider] - filters to packages with Appstream entries
/// 3. [debsWithUpdatesProvider] - update version info
/// 4. [packageDetailsProvider] - size and description
@riverpod
Future<List<LocalDebInfo>> localDebs(Ref ref) async {
  final installed = await ref.watch(installedPackagesProvider.future);
  final componentsByPkg = await ref.watch(componentsByPackageProvider.future);
  final updatesMap = await ref.watch(debsWithUpdatesProvider.future);

  // Filter to packages with Appstream entries
  final guiPackages = installed
      .where((pkg) => componentsByPkg.containsKey(pkg.packageId.name))
      .toList();

  final packageIds = guiPackages.map((p) => p.packageId).toList();
  final details = await ref.watch(packageDetailsProvider(packageIds).future);

  return guiPackages.map((pkg) {
    final name = pkg.packageId.name;
    final component = componentsByPkg[name];
    return LocalDebInfo(
      id: component?.id ?? name,
      packageInfo: pkg,
      component: component,
      details: details[name],
      updatePackageId: updatesMap[name],
    );
  }).toList();
}
