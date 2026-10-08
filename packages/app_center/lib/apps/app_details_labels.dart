import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yaru/yaru.dart';

const kMissingValue = '—';

String formatAppDate(DateTime date) => DateFormat.yMMMd().format(date);

extension ActionKindL10n on ActionKind {
  String localize(AppLocalizations l10n) => switch (this) {
    ActionKind.install => l10n.snapActionInstallLabel,
    ActionKind.update => l10n.snapActionUpdateLabel,
    ActionKind.open => l10n.snapActionOpenLabel,
    ActionKind.uninstall => l10n.snapActionRemoveLabel,
    ActionKind.switchChannel => l10n.snapActionSwitchChannelLabel,
    ActionKind.cancel => l10n.snapActionCancelLabel,
  };
}

extension OperationKindL10n on OperationKind {
  String localize(AppLocalizations l10n) => switch (this) {
    OperationKind.install => l10n.snapActionInstallingLabel,
    OperationKind.update => l10n.snapActionUpdatingLabel,
    OperationKind.remove => l10n.snapActionRemovingLabel,
    OperationKind.switchChannel => l10n.snapActionSwitchChannelLabel,
  };
}

extension PackageFormatL10n on PackageFormat {
  String localize(AppLocalizations l10n) => switch (this) {
    PackageFormat.snap => l10n.managePagePackageTypeSnap,
    PackageFormat.deb => l10n.managePagePackageTypeDeb,
  };
}

class ConfinementLabel extends StatelessWidget {
  const ConfinementLabel(this.confinement, {super.key});

  final AppConfinement confinement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      constraints: const BoxConstraints(maxWidth: 200),
      message: confinement.localizeTooltip(l10n) ?? '',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (confinement == AppConfinement.strict) ...const [
            Icon(YaruIcons.shield, size: 12),
            SizedBox(width: 2),
          ],
          Text(confinement.localize(l10n)),
        ],
      ),
    );
  }
}
