import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class QuitToUpdateNotice extends StatelessWidget {
  const QuitToUpdateNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final colorScheme = theme.colorScheme;
    final isHighContrast = MediaQuery.highContrastOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          YaruIcons.warning_filled,
          color: isHighContrast
              ? theme.textTheme.bodyMedium?.color
              : colorScheme.warning,
        ),
        const SizedBox(width: kSpacingSmall),
        Text(
          l10n.managePageQuitToUpdate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
