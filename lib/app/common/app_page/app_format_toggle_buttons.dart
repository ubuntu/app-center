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
        children: const [
          SnapLabel(),
          DebianLabel(),
        ],
      ),
    );
  }
}

class SnapLabel extends StatelessWidget {
  const SnapLabel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 10,
        ),
        Icon(
          YaruIcons.snapcraft,
          color: theme.colorScheme.onSurface,
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
    );
  }
}

class DebianLabel extends StatelessWidget {
  const DebianLabel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 10,
        ),
        Icon(
          YaruIcons.debian,
          color: theme.colorScheme.onSurface,
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
    );
  }
}
