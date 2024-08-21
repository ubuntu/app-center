import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

class DialogAction<T> {
  const DialogAction({
    required this.value,
    required this.label,
    this.isPrimary = false,
  });
  final T value;
  final bool isPrimary;
  final String label;
}

Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
  YaruInfoType type = YaruInfoType.danger,
  TextStyle? titleTextStyle,
}) {
  final titleStyle = titleTextStyle ?? Theme.of(context).textTheme.titleMedium!;
  return showYaruInfoDialog(
    context: context,
    actions: [
      DialogAction(
        value: null,
        label: UbuntuLocalizations.of(context).okLabel,
      ),
    ],
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: titleStyle.fontSize! * 1.5,
          child: Text(
            title,
            style: titleStyle,
          ),
        ),
        const SizedBox(height: 8),
        Text(message),
      ],
    ),
    type: type,
  );
}

Future<T?> showYaruInfoDialog<T>({
  required BuildContext context,
  required Widget child,
  required YaruInfoType type,
  required List<DialogAction<T>> actions,
}) =>
    showDialog(
      context: context,
      builder: (context) => _Dialog(
        type: type,
        actions: actions,
        child: child,
      ),
    );

class _Dialog<T> extends StatelessWidget {
  const _Dialog({
    required this.child,
    required this.type,
    required this.actions,
  });
  final Widget child;
  final YaruInfoType type;
  final List<DialogAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24.0),
      actions: actions.map((action) {
        final button =
            action.isPrimary ? PushButton.elevated : PushButton.outlined;
        return button(
          onPressed: () => Navigator.of(context).pop(action.value),
          child: Text(action.label),
        );
      }).toList(),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxDialogWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(type.iconData, color: type.getColor(context), size: 48.0),
            const SizedBox(width: 16.0),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
