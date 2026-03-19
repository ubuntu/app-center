import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snapd/snapd.dart';

part 'manage_app_data.freezed.dart';

/// Unified data model for displaying both snap and deb packages on the manage
/// page. Provides a common interface for properties like name, icon, version,
/// and update status so the UI can treat both package types uniformly.
@freezed
class ManageAppData with _$ManageAppData {
  /// A snap package, with an optional [updateVersion] when an update is available.
  const factory ManageAppData.snap({
    required Snap snap,
    String? updateVersion,
  }) = ManageSnapData;

  /// A deb package, backed by [LocalDebInfo] which aggregates PackageKit and
  /// Appstream data.
  const factory ManageAppData.localDeb({
    required LocalDebInfo debInfo,
  }) = ManageDebData;

  const ManageAppData._();

  /// Unique identifier: snap ID or Appstream component ID (falling back to
  /// package name).
  String get id => when(
        snap: (snap, _) => snap.id,
        localDeb: (debInfo) => debInfo.id,
      );

  /// Display name: snap title or localized Appstream name.
  String get name => when(
        snap: (snap, _) => snap.titleOrName,
        localDeb: (debInfo) =>
            debInfo.component?.getLocalizedName() ??
            debInfo.packageInfo.packageId.name,
      );

  /// Icon URL for display in the app list.
  String? get iconUrl => when(
        snap: (snap, _) => snap.iconUrl,
        localDeb: (debInfo) => debInfo.component?.icon,
      );

  /// Whether this package has a pending update.
  bool get hasUpdate => when(
        snap: (_, updateVersion) => updateVersion != null,
        localDeb: (debInfo) => debInfo.hasUpdate,
      );

  /// Whether this is a user-facing app (has desktop entries or Appstream data)
  /// vs a system/library package.
  bool get isLaunchable => when(
        snap: (snap, _) => snap.apps.isNotEmpty,
        localDeb: (debInfo) => debInfo.hasAppstreamEntry,
      );

  /// Install/release date. For snaps, this is the install date. For debs,
  /// this is the release date of the installed version from AppStream metadata.
  DateTime? get installDate => when(
        snap: (snap, _) => snap.installDate,
        localDeb: (debInfo) => debInfo.releaseDate,
      );

  /// Installed size in bytes, used for sort-by-size.
  int? get installedSize => when(
        snap: (snap, _) => snap.installedSize,
        localDeb: (debInfo) => debInfo.details?.size,
      );

  /// Currently installed version string.
  String get version => when(
        snap: (snap, _) => snap.version,
        localDeb: (debInfo) => debInfo.packageInfo.packageId.version,
      );
}

/// Sort order for apps on the manage page.
enum AppSortOrder {
  alphabeticalAsc,
  alphabeticalDesc,
  installedDateAsc,
  installedDateDesc,
  installedSizeAsc,
  installedSizeDesc;

  String localize(AppLocalizations l10n) {
    return switch (this) {
      AppSortOrder.alphabeticalAsc => l10n.snapSortOrderAlphabeticalAsc,
      AppSortOrder.alphabeticalDesc => l10n.snapSortOrderAlphabeticalDesc,
      AppSortOrder.installedDateAsc => l10n.snapSortOrderInstalledDateAsc,
      AppSortOrder.installedDateDesc => l10n.snapSortOrderInstalledDateDesc,
      AppSortOrder.installedSizeAsc => l10n.snapSortOrderInstalledSizeAsc,
      AppSortOrder.installedSizeDesc => l10n.snapSortOrderInstalledSizeDesc,
    };
  }
}

/// Sorting extension for [ManageAppData] lists. Items with null values for the
/// sorted field (e.g. debs have no install date) are pushed to the end.
extension ManageAppSort on Iterable<ManageAppData> {
  /// Returns a new sorted list according to the given [order].
  List<ManageAppData> sortedApps(AppSortOrder order) {
    final list = toList();
    list.sort((a, b) {
      return switch (order) {
        AppSortOrder.alphabeticalAsc =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        AppSortOrder.alphabeticalDesc =>
          b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        AppSortOrder.installedDateAsc => _compareDates(a, b, ascending: true),
        AppSortOrder.installedDateDesc => _compareDates(a, b, ascending: false),
        AppSortOrder.installedSizeAsc => _compareSizes(a, b, ascending: true),
        AppSortOrder.installedSizeDesc => _compareSizes(a, b, ascending: false),
      };
    });
    return list;
  }

  int _compareDates(
    ManageAppData a,
    ManageAppData b, {
    required bool ascending,
  }) {
    // Items without dates sort to end
    if (a.installDate == null && b.installDate == null) return 0;
    if (a.installDate == null) return 1;
    if (b.installDate == null) return -1;
    return ascending
        ? a.installDate!.compareTo(b.installDate!)
        : b.installDate!.compareTo(a.installDate!);
  }

  int _compareSizes(
    ManageAppData a,
    ManageAppData b, {
    required bool ascending,
  }) {
    // Items without sizes sort to end
    if (a.installedSize == null && b.installedSize == null) return 0;
    if (a.installedSize == null) return 1;
    if (b.installedSize == null) return -1;
    return ascending
        ? a.installedSize!.compareTo(b.installedSize!)
        : b.installedSize!.compareTo(a.installedSize!);
  }
}
