import 'package:app_center/l10n.dart';
import 'package:app_center/src/snapd/snap_sort.dart';
import 'package:snapd/snapd.dart';

extension SnapdChangeL10n on SnapdChange {
  String? localize(AppLocalizations l10n) => switch (kind) {
        'install-snap' => l10n.snapActionInstallingLabel,
        'refresh-snap' => l10n.snapActionUpdatingLabel,
        'remove-snap' => l10n.snapActionRemovingLabel,
        _ => null,
      };
}

extension SnapConfinementL10n on SnapConfinement {
  String localize(AppLocalizations l10n) => switch (this) {
        SnapConfinement.classic => l10n.snapConfinementClassic,
        SnapConfinement.devmode => l10n.snapConfinementDevmode,
        SnapConfinement.strict => l10n.snapConfinementStrict,
        _ => name,
      };
}

extension SnapSortOrderL10n on SnapSortOrder {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      SnapSortOrder.alphabeticalAsc => l10n.snapSortOrderAlphabeticalAsc,
      SnapSortOrder.alphabeticalDesc => l10n.snapSortOrderAlphabeticalDesc,
      SnapSortOrder.downloadSizeAsc => l10n.snapSortOrderDownloadSizeAsc,
      SnapSortOrder.downloadSizeDesc => l10n.snapSortOrderDownloadSizeDesc,
      SnapSortOrder.installedDateAsc => l10n.snapSortOrderInstalledDateAsc,
      SnapSortOrder.installedDateDesc => l10n.snapSortOrderInstalledDateDesc,
      SnapSortOrder.installedSizeAsc => l10n.snapSortOrderInstalledSizeAsc,
      SnapSortOrder.installedSizeDesc => l10n.snapSortOrderInstalledSizeDesc,
    };
  }
}
