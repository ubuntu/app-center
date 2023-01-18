import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/common/snap/snap_connections_settings.dart';
import 'package:software/app/common/snap/snap_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapConnectionsDialog extends StatelessWidget {
  const SnapConnectionsDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final snapChangeInProgress =
        context.select((SnapModel m) => m.snapChangeInProgress);
    final plugs = context.select((SnapModel m) => m.plugs);
    final toggleConnection =
        context.select((SnapModel m) => m.toggleConnection);

    return SimpleDialog(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kYaruPagePadding,
        vertical: kYaruPagePadding / 2,
      ),
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        title: Text(context.l10n.permissions),
      ),
      children: [
        SnapConnectionsSettings(
          snapChangeInProgress: snapChangeInProgress,
          plugs: plugs ?? {},
          toggleConnection: toggleConnection,
        )
      ],
    );
  }
}
