import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MessageBar extends StatelessWidget {
  const MessageBar({
    super.key,
    required this.message,
    required this.copyMessage,
  });

  final String message;
  final String copyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        YaruDialogTitleBar(
          title: TextButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  YaruIcons.copy,
                  color: Theme.of(context).primaryColor,
                ),
                Text(
                  copyMessage,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              ],
            ),
            onPressed: () => Clipboard.setData(ClipboardData(text: message)),
          ),
          onClose: (context) => ScaffoldMessenger.of(context).clearSnackBars(),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400, minHeight: 200),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(kYaruPagePadding),
              child: SelectableText(message),
            ),
          ),
        ),
      ],
    );
  }
}
