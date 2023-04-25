import 'package:flutter/material.dart';
import 'package:software/app/common/app_format.dart';
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
          AppFormatLabel(
            appFormat: AppFormat.snap,
            isSelected: isSelected[0],
          ),
          AppFormatLabel(
            appFormat: AppFormat.packageKit,
            isSelected: isSelected[1],
          )
        ],
      ),
    );
  }
}

class AppFormatLabel extends StatelessWidget {
  const AppFormatLabel({
    super.key,
    required this.appFormat,
    required this.isSelected,
  });

  final AppFormat appFormat;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 10,
        ),
        if (appFormat == AppFormat.snap)
          Icon(
            YaruIcons.snapcraft,
            color: theme.colorScheme.onSurface,
            size: 16,
          )
        else
          Icon(
            YaruIcons.debian,
            color: theme.colorScheme.onSurface,
            size: 16,
          ),
        const SizedBox(
          width: 5,
        ),
        if (appFormat == AppFormat.snap)
          Text(
            context.l10n.snapPackage,
            style: isSelected
                ? const TextStyle(fontWeight: FontWeight.w500)
                : null,
          )
        else
          Text(
            context.l10n.debianPackage,
            style: isSelected
                ? const TextStyle(fontWeight: FontWeight.w500)
                : null,
          ),
        const SizedBox(
          width: 10,
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }
}
