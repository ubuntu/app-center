import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapInstallationControls extends StatelessWidget {
  const SnapInstallationControls({
    super.key,
    required this.appChangeInProgress,
    required this.appIsInstalled,
    required this.remove,
    required this.refresh,
    required this.install,
  });

  final bool appChangeInProgress;
  final bool appIsInstalled;
  final Function() remove;
  final Function() refresh;
  final Function() install;

  @override
  Widget build(BuildContext context) {
    if (appChangeInProgress) {
      return const SizedBox(
        height: 25,
        child: YaruCircularProgressIndicator(
          strokeWidth: 3,
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (appIsInstalled)
            OutlinedButton(
              onPressed: remove,
              child: Text(
                context.l10n.remove,
                style: appChangeInProgress
                    ? TextStyle(color: Theme.of(context).disabledColor)
                    : null,
              ),
            ),
          const SizedBox(
            width: 10,
          ),
          if (appIsInstalled)
            OutlinedButton(
              onPressed: refresh,
              child: Text(context.l10n.refresh),
            )
          else
            ElevatedButton(
              onPressed: appChangeInProgress ? null : install,
              child: Text(context.l10n.install),
            ),
        ],
      );
    }
  }
}
