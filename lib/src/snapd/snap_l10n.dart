import 'package:snapd/snapd.dart';

import '/l10n.dart';

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
