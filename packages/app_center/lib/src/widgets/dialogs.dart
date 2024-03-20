import 'package:app_center/l10n.dart';
import 'package:flutter/material.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/icons.dart';

const kMaxWidth = 500.0;

Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
  IconData? icon,
}) {
  return showDialog(
    context: context,
    builder: (context) => ErrorDialog(
      title: title,
      message: message,
      icon: icon,
    ),
  );
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({
    required this.title,
    required this.message,
    super.key,
    this.icon,
  });

  final String title;
  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final l10n = UbuntuLocalizations.of(context);
    return AlertDialog(
      actions: [
        PushButton.filled(
          onPressed: Navigator.of(context).pop,
          child: Text(l10n.closeLabel),
        )
      ],
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxWidth),
        child: Row(
          children: [
            Icon(
              icon ?? YaruIcons.error,
              color: Theme.of(context).colorScheme.error,
              size: 64.0,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Theme.of(context).textTheme.titleMedium!.fontSize! *
                        1.5,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: add confirmation dialogs (issue #1398)
