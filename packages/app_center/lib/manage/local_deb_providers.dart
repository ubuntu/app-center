import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
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
/// - [hasDesktopEntry]: Whether a package without Appstream metadata still
///   ships a desktop entry (e.g. third-party debs)
/// - [packageInfo]: PackageKit package info (version, architecture)
/// - [details]: PackageKit details (size, description) - fetched separately
/// - [updateVersion]: Available update version, if any
/// - [activeTransactionId]: Tracks ongoing install/remove/update operations
@freezed
abstract class LocalDebInfo with _$LocalDebInfo {
  factory LocalDebInfo({
    required String id,
    required PackageKitPackageEvent packageInfo,
    AppstreamComponent? component,
    @Default(false) bool hasDesktopEntry,
    PackageKitPackageId? updatePackageId,
    PackageKitDetailsEvent? details,
    int? activeTransactionId,
  }) = _LocalDebInfo;

  const LocalDebInfo._();

  bool get hasUpdate => updatePackageId != null;
  String? get updateVersion => updatePackageId?.version;

  /// Whether this deb has an Appstream entry (user-facing app vs system package).
  bool get hasAppstreamEntry => component != null;

  /// Returns true if this package is compulsory for any of the given [desktops].
  bool isCompulsoryFor(List<String> desktops) =>
      component?.isCompulsoryFor(desktops) ?? false;

  /// Returns the release date for the currently installed version from
  /// AppStream metadata, or the most recent release date if no exact match.
  DateTime? get releaseDate {
    final installedVersion = packageInfo.packageId.version;
    // Try to find exact version match
    final matchingRelease = component?.releases.firstWhereOrNull(
      (r) => r.version == installedVersion,
    );
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

// The apt backend prefixes the package ID data with `manual:` or `auto:`.
bool _isManuallyInstalled(PackageKitPackageId id) =>
    id.data.startsWith('manual:');

bool _isDesktopEntry(String path) =>
    path.startsWith('/usr/share/applications/') && path.endsWith('.desktop');

/// Returns the names of manually installed packages that have no Appstream
/// component but ship a desktop entry, e.g. third-party debs like Google Chrome.
@riverpod
Future<Set<String>> desktopAppPackages(Ref ref) async {
  // Watch both before awaiting: callers that only `read` this provider let it
  // dispose mid-flight, and `ref` can't be used after that.
  final installedFuture = ref.watch(installedPackagesProvider.future);
  final componentsFuture = ref.watch(componentsByPackageProvider.future);
  final installed = await installedFuture;
  final componentsByPkg = await componentsFuture;
  final candidates = installed
      .map((pkg) => pkg.packageId)
      .where(
        (id) =>
            _isManuallyInstalled(id) && !componentsByPkg.containsKey(id.name),
      );
  final files = await getService<PackageKitService>().getFiles(candidates);
  return {
    for (final entry in files.entries)
      if (entry.value.any(_isDesktopEntry)) entry.key,
  };
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

/// Aggregates installed deb packages, filtered to those with Appstream entries
/// or, for manually installed third-party debs, a desktop entry.
///
/// Combines data from:
/// 1. [installedPackagesProvider] - all installed packages
/// 2. [componentsByPackageProvider] - packages with Appstream entries
/// 3. [desktopAppPackagesProvider] - packages without Appstream entries that
///    ship a desktop entry
/// 4. [debsWithUpdatesProvider] - update version info
/// 5. [packageDetailsProvider] - size and description
@riverpod
Future<List<LocalDebInfo>> localDebs(Ref ref) async {
  final installed = await ref.watch(installedPackagesProvider.future);
  final componentsByPkg = await ref.watch(componentsByPackageProvider.future);
  final desktopApps = await ref.watch(desktopAppPackagesProvider.future);
  final updatesMap = await ref.watch(debsWithUpdatesProvider.future);

  final guiPackages = installed
      .where(
        (pkg) =>
            componentsByPkg.containsKey(pkg.packageId.name) ||
            desktopApps.contains(pkg.packageId.name),
      )
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
      hasDesktopEntry: desktopApps.contains(name),
      details: details[name],
      updatePackageId: updatesMap[name],
    );
  }).toList();
}
