import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class ActiveChangeContent extends ConsumerWidget {
  const ActiveChangeContent(this.changeId, {super.key});

  final String changeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final change = ref.watch(activeChangeProvider(changeId));

    return Row(
      children: [
        SizedBox.square(
          dimension: kCircularProgressIndicatorHeight,
          child: YaruCircularProgressIndicator(
            value: change?.progress,
            strokeWidth: 2,
          ),
        ),
        if (change != null) ...[
          const SizedBox(width: 8),
          Text(
            change.localize(l10n) ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class CancelActiveChangeButton extends ConsumerWidget {
  const CancelActiveChangeButton(this.snapName, {super.key});

  final String? snapName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton(
      onPressed: snapName != null
          ? () => ref.read(snapModelProvider(snapName!).notifier).cancel()
          : null,
      child: Text(
        l10n.snapActionCancelLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
