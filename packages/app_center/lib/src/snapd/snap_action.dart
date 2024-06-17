import 'package:app_center/l10n.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/snap_data.dart';
import 'package:flutter/widgets.dart';
import 'package:yaru/icons.dart';

enum SnapAction {
  cancel,
  install,
  open,
  remove,
  switchChannel,
  update;

  String label(AppLocalizations l10n) => switch (this) {
        cancel => l10n.snapActionCancelLabel,
        install => l10n.snapActionInstallLabel,
        open => l10n.snapActionOpenLabel,
        remove => l10n.snapActionRemoveLabel,
        switchChannel => l10n.snapActionSwitchChannelLabel,
        update => l10n.snapActionUpdateLabel,
      };

  IconData? get icon => switch (this) {
        update => YaruIcons.refresh,
        remove => YaruIcons.trash,
        _ => null,
      };

  void Function()? callback(
    SnapData? snapData,
    SnapModel model, [
    SnapLauncher? launcher,
  ]) {
    return switch (this) {
      SnapAction.cancel => model.cancel,
      SnapAction.install => snapData?.storeSnap != null ? model.install : null,
      SnapAction.open =>
        launcher?.isLaunchable ?? false ? launcher!.open : null,
      SnapAction.remove => model.remove,
      SnapAction.switchChannel =>
        snapData?.storeSnap != null ? model.refresh : null,
      SnapAction.update => snapData?.storeSnap != null ? model.refresh : null,
    };
  }
}
