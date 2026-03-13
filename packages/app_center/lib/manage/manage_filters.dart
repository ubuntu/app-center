import 'package:app_center/l10n.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filter for the combined app list (search text).
final appFilterProvider = StateProvider.autoDispose<String>((_) => '');

/// Toggle for showing system apps (non-launchable).
final showSystemAppsProvider = StateProvider<bool>((_) => false);

/// Filter for package type (all, snap, deb).
enum PackageTypeFilter { all, snap, deb }

final packageTypeFilterProvider =
    StateProvider<PackageTypeFilter>((_) => PackageTypeFilter.all);

extension PackageTypeFilterL10n on PackageTypeFilter {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      PackageTypeFilter.all => l10n.managePagePackageTypeAll,
      PackageTypeFilter.snap => l10n.managePagePackageTypeSnap,
      PackageTypeFilter.deb => l10n.managePagePackageTypeDeb,
    };
  }
}

/// Sort order for the combined app list.
enum AppSortOrder {
  alphabeticalAsc,
  alphabeticalDesc,
  installedDateAsc,
  installedDateDesc,
  installedSizeAsc,
  installedSizeDesc,
}

final appSortOrderProvider =
    StateProvider<AppSortOrder>((_) => AppSortOrder.alphabeticalAsc);

extension AppSortOrderL10n on AppSortOrder {
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

extension AppSort on List<ManageAppData> {
  List<ManageAppData> sortedApps(AppSortOrder order) {
    final sorted = List<ManageAppData>.from(this);
    sorted.sort(
      (a, b) => switch (order) {
        AppSortOrder.alphabeticalAsc =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        AppSortOrder.alphabeticalDesc =>
          b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        AppSortOrder.installedDateAsc => _compareDates(a, b, ascending: true),
        AppSortOrder.installedDateDesc => _compareDates(a, b, ascending: false),
        AppSortOrder.installedSizeAsc => _compareSizes(a, b, ascending: true),
        AppSortOrder.installedSizeDesc => _compareSizes(a, b, ascending: false),
      },
    );
    return sorted;
  }

  int _compareDates(
    ManageAppData a,
    ManageAppData b, {
    required bool ascending,
  }) {
    final dateA = a.installDate;
    final dateB = b.installDate;

    if (dateA == null && dateB == null) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
    if (dateA == null) return 1;
    if (dateB == null) return -1;

    return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
  }

  int _compareSizes(
    ManageAppData a,
    ManageAppData b, {
    required bool ascending,
  }) {
    final sizeA = a.installedSize;
    final sizeB = b.installedSize;

    if (sizeA == null && sizeB == null) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
    if (sizeA == null) return 1;
    if (sizeB == null) return -1;

    return ascending ? sizeA.compareTo(sizeB) : sizeB.compareTo(sizeA);
  }
}
