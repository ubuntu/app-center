import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppFormatToggleButtons extends StatelessWidget {
  const AppFormatToggleButtons({
    super.key,
    this.onPressed,
    required this.isSelected,
  });

  final void Function(int)? onPressed;
  final List<bool> isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ToggleButtons(
        isSelected: isSelected,
        onPressed: onPressed,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              const Icon(
                YaruIcons.snapcraft,
                size: 16,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(context.l10n.snapPackage),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              const Icon(
                YaruIcons.debian,
                size: 16,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(context.l10n.debianPackage),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
