import 'package:app_center/constants.dart';
import 'package:app_center/extensions/iterable_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class ActiveChangeStatus extends StatelessWidget {
  const ActiveChangeStatus({
    required this.snapName,
    required this.activeChangeId,
    super.key,
  });

  final String? snapName;
  final String activeChangeId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActiveChangeText(activeChangeId),
        _CancelActiveChangeButton(snapName),
      ].separatedBy(const SizedBox(width: kSpacing)),
    );
  }
}

class _ActiveChangeText extends ConsumerWidget {
  const _ActiveChangeText(this.changeId);

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
          const SizedBox(width: kSpacingSmall),
          Text(
            change.localize(l10n) ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

//
class _CancelActiveChangeButton extends ConsumerStatefulWidget {
  const _CancelActiveChangeButton(this.snapName);

  final String? snapName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      ConsumerActiveChangeButtonState();
}

class ConsumerActiveChangeButtonState
    extends ConsumerState<_CancelActiveChangeButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton(
      onPressed: widget.snapName != null && !isPressed
          ? () {
              setState(() {
                isPressed = true;
                ref.read(snapModelProvider(widget.snapName!).notifier).cancel();
              });
            }
          : null,
      child: Text(
        l10n.snapActionCancelLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
