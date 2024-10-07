import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class UpdateButton extends ConsumerWidget {
  const UpdateButton({
    required this.snapModel,
    required this.activeChangeId,
    super.key,
  });

  final AsyncValue<SnapData> snapModel;
  final String? activeChangeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final shouldQuitToUpdate =
        snapModel.valueOrNull?.localSnap?.refreshInhibit != null;
    final snap =
        snapModel.valueOrNull?.localSnap ?? snapModel.valueOrNull?.storeSnap;

    if (shouldQuitToUpdate) {
      return const QuitToUpdateNotice();
    } else {
      return OutlinedButton(
        onPressed: activeChangeId != null || !snapModel.hasValue
            ? null
            : ref.read(snapModelProvider(snap!.name).notifier).refresh,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(YaruIcons.download),
            const SizedBox(width: kSpacingSmall),
            Text(
              l10n.snapActionUpdateLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
  }
}

@visibleForTesting
class QuitToUpdateNotice extends StatelessWidget {
  const QuitToUpdateNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(YaruIcons.warning_filled, color: colorScheme.warning),
        const SizedBox(width: 8),
        Text(
          l10n.managePageQuitToUpdate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
