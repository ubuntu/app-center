import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SnapConnectionsButton extends StatelessWidget {
  const SnapConnectionsButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          const Icon(
            YaruIcons.lock,
            size: 18,
          ),
          Text(context.l10n.permissions),
        ],
      ),
    );
  }
}
