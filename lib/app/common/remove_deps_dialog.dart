import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RemoveDepsDialog extends StatelessWidget {
  const RemoveDepsDialog({super.key, this.removeDeps, this.dontRemoveDeps});

  final VoidCallback? removeDeps;
  final VoidCallback? dontRemoveDeps;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: 500,
        child: YaruDialogTitleBar(
          title: Text(context.l10n.dependencies),
        ),
      ),
      titlePadding: EdgeInsets.zero,
      content: Text(context.l10n.dependencyRemovalChoice),
      actions: [
        OutlinedButton(
          onPressed: () {
            dontRemoveDeps?.call();
            Navigator.pop(context);
          },
          child: Text(context.l10n.no),
        ),
        ElevatedButton(
          onPressed: () {
            removeDeps?.call();
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.yes),
        )
      ],
    );
  }
}
