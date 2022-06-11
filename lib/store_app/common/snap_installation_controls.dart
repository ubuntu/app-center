import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapInstallationControls extends StatelessWidget {
  const SnapInstallationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    if (model.appChangeInProgress) {
      return const SizedBox(
        height: 25,
        child: YaruCircularProgressIndicator(
          strokeWidth: 3,
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (model.snapIsInstalled)
            OutlinedButton(
              onPressed: () => model.removeSnap(),
              child: Text(
                context.l10n.remove,
                style: model.appChangeInProgress
                    ? TextStyle(color: Theme.of(context).disabledColor)
                    : null,
              ),
            ),
          const SizedBox(
            width: 10,
          ),
          if (model.snapIsInstalled)
            OutlinedButton(
              onPressed: () => model.refreshSnapApp(),
              child: Text(context.l10n.refresh),
            )
          else
            ElevatedButton(
              onPressed:
                  model.appChangeInProgress ? null : () => model.installSnap(),
              child: Text(context.l10n.install),
            ),
        ],
      );
    }
  }
}
