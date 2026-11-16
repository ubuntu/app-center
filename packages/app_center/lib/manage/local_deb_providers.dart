import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/manage/logger.dart';
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

// Package ID data is `<auto|manual>:<origin>`, e.g. `manual:local`.
// Ubuntu origins are skipped so they can't bypass the compulsory check.
bool _isManualThirdPartyInstall(PackageKitPackageId id) {
  const prefix = 'manual:';
  return id.data.startsWith(prefix) &&
      !id.data.substring(prefix.length).startsWith('ubuntu');
}

bool _hasInstallReason(PackageKitPackageId id) =>
    id.data.startsWith('manual:') || id.data.startsWith('auto:');

// Must stay a path check: the confined snap can't read the host's files.
bool _isDesktopEntry(String path) =>
    path.startsWith('/usr/share/applications/') && path.endsWith('.desktop');

/// Whether a package (by name and version) ships a desktop entry. File lists
/// only change with the version, so lookups are kept for the app's lifetime.
@Riverpod(keepAlive: true)
Map<(String, String), bool> desktopEntryCache(Ref ref) => {};

/// Returns the names of manually installed third-party packages that have no
/// Appstream component but ship a desktop entry, e.g. Google Chrome.
@riverpod
Future<Set<String>> desktopAppPackages(Ref ref) async {
  // Watch before awaiting: callers that only `read` this provider let it
  // dispose mid-flight, and `ref` can't be used after that.
  final installedFuture = ref.watch(installedPackagesProvider.future);
  final componentsFuture = ref.watch(componentsByPackageProvider.future);
  final cache = ref.watch(desktopEntryCacheProvider);
  final installed = await installedFuture;
  final componentsByPkg = await componentsFuture;

  if (installed.isNotEmpty &&
      !installed.any((pkg) => _hasInstallReason(pkg.packageId))) {
    log.warning(
      'No installed package ID has a manual:/auto: prefix, '
      'third-party debs are not listed',
    );
  }

  (String, String) key(PackageKitPackageId id) => (id.name, id.version);
  final candidates = installed
      .map((pkg) => pkg.packageId)
      .where(
        (id) =>
            _isManualThirdPartyInstall(id) &&
            !componentsByPkg.containsKey(id.name),
      )
      .toList();
  final unknown = candidates
      .where((id) => !cache.containsKey(key(id)))
      .toList();
  if (unknown.isNotEmpty) {
    try {
      final files = await getService<PackageKitService>().getFiles(unknown);
      for (final id in unknown) {
        cache[key(id)] = files[id.name]?.any(_isDesktopEntry) ?? false;
      }
    } on Exception catch (e) {
      log.warning('Could not list files of installed packages: $e');
    }
  }
  return {
    for (final id in candidates)
      if (cache[key(id)] ?? false) id.name,
  };
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

/// Aggregates installed deb packages, filtered to those with Appstream entries
/// or, for manually installed third-party debs, a desktop entry.
///
/// Combines data from:
/// 1. [installedPackagesProvider] - all installed packages
/// 2. [componentsByPackageProvider] - packages with Appstream entries
/// 3. [desktopAppPackagesProvider] - packages without Appstream entries that
///    ship a desktop entry; merged in once known, so it never delays the list
/// 4. [debsWithUpdatesProvider] - update version info
/// 5. PackageKit details - size and description
@riverpod
Future<List<LocalDebInfo>> localDebs(Ref ref) async {
  // Watch before awaiting: desktop apps arriving rebuilds this mid-flight.
  final desktopApps =
      ref.watch(desktopAppPackagesProvider.select((s) => s.value)) ??
      const <String>{};
  final installedFuture = ref.watch(installedPackagesProvider.future);
  final componentsFuture = ref.watch(componentsByPackageProvider.future);
  final updatesFuture = ref.watch(debsWithUpdatesProvider.future);
  final installed = await installedFuture;
  final componentsByPkg = await componentsFuture;
  final updatesMap = await updatesFuture;

  final guiPackages = installed
      .where(
        (pkg) =>
            componentsByPkg.containsKey(pkg.packageId.name) ||
            desktopApps.contains(pkg.packageId.name),
      )
      .toList();

  final details = guiPackages.isEmpty
      ? const <String, PackageKitDetailsEvent>{}
      : await getService<PackageKitService>().getDetails(
          guiPackages.map((p) => p.packageId).toList(),
        );
  // A rebuild mid-transaction must keep the progress and Cancel controls.
  final activeMutations = getService<PackageKitService>().activeMutations;

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
      activeTransactionId: activeMutations
          .firstWhereOrNull((m) => m.affects(name))
          ?.transactionId,
    );
  }).toList();
}
