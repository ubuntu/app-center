import 'package:app_center/l10n.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/dialogs.dart';
import 'package:flutter/widgets.dart';
import 'package:yaru/icons.dart';

enum SnapAction {
  cancel,
  install,
  open,
  remove,
  revert,
  switchChannel,
  update;

  String label(AppLocalizations l10n) => switch (this) {
        cancel => l10n.snapActionCancelLabel,
        install => l10n.snapActionInstallLabel,
        open => l10n.snapActionOpenLabel,
        remove => l10n.snapActionRemoveLabel,
        revert => l10n.snapActionRevertLabel,
        switchChannel => l10n.snapActionSwitchChannelLabel,
        update => l10n.snapActionUpdateLabel,
      };

  IconData? get icon => switch (this) {
        update => YaruIcons.refresh,
        remove => YaruIcons.trash,
        revert => YaruIcons.undo,
        _ => null,
      };

  void Function()? callback(
    SnapData? snapData,
    SnapModel model, [
    SnapLauncher? launcher,
    BuildContext? context,
  ]) {
    return switch (this) {
      SnapAction.cancel => model.cancel,
      SnapAction.install => snapData?.storeSnap != null ? model.install : null,
      SnapAction.open =>
        launcher?.isLaunchable ?? false ? launcher!.open : null,
      SnapAction.remove => model.remove,
      SnapAction.revert => (snapData?.canRevert ?? false)
          ? () => confirmRevertAndRun(context!, snapData!, model)
          : null,
      SnapAction.switchChannel =>
        snapData?.storeSnap != null ? model.refresh : null,
      SnapAction.update => snapData?.storeSnap != null ? model.refresh : null,
    };
  }
}
