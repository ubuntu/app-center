import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

enum DialogAction { primaryAction, secondaryAction }

Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
}) =>
    showYaruInfoDialog(
      context: context,
      secondaryActionLabel: UbuntuLocalizations.of(context).closeLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Theme.of(context).textTheme.titleMedium!.fontSize! * 1.5,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
      type: YaruInfoType.danger,
    );

Future<DialogAction?> showYaruInfoDialog({
  required BuildContext context,
  required Widget child,
  required YaruInfoType type,
  String? primaryActionLabel,
  String? secondaryActionLabel,
}) =>
    showDialog<DialogAction>(
      context: context,
      builder: (context) => _Dialog(
        type: type,
        primaryActionLabel: primaryActionLabel,
        secondaryActionLabel: secondaryActionLabel,
        child: child,
      ),
    );

class _Dialog extends StatelessWidget {
  const _Dialog({
    required this.child,
    required this.type,
    this.primaryActionLabel,
    this.secondaryActionLabel,
  }) : assert(
          primaryActionLabel != null || secondaryActionLabel != null,
          'At least one action label must be provided',
        );
  final Widget child;
  final YaruInfoType type;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        if (secondaryActionLabel != null)
          PushButton.outlined(
            onPressed: () =>
                Navigator.of(context).pop(DialogAction.secondaryAction),
            child: Text(secondaryActionLabel!),
          ),
        if (primaryActionLabel != null)
          PushButton.elevated(
            onPressed: () =>
                Navigator.of(context).pop(DialogAction.primaryAction),
            child: Text(primaryActionLabel!),
          ),
      ],
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxDialogWidth),
        child: Row(
          children: [
            Icon(type.iconData, color: type.getColor(context), size: 64.0),
            const SizedBox(width: 16.0),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
