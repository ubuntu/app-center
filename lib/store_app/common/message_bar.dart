import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MessageBar extends StatelessWidget {
  const MessageBar({super.key, required this.messsage});

  final String messsage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        YaruTitleBar(
          title: TextButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(YaruIcons.edit_copy),
                Text(context.l10n.copyErrorMessage)
              ],
            ),
            onPressed: () {},
          ),
          trailing: YaruCloseButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(kYaruPagePadding),
              child: SelectableText(messsage),
            ),
          ),
        ),
      ],
    );
  }
}
