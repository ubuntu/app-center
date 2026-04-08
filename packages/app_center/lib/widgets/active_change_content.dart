import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class ActiveChangeStatus extends StatelessWidget {
  const ActiveChangeStatus({
    required this.onCancelPressed,
    required this.progress,
    this.actionLabel,
    super.key,
  });

  final void Function(WidgetRef ref)? onCancelPressed;
  final double progress;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActiveChangeText(
          label: actionLabel,
          progress: progress,
        ),
        _CancelActiveChangeButton(
          onCancelPressed: onCancelPressed,
        ),
      ].separatedBy(const SizedBox(width: kSpacing)),
    );
  }
}

class _ActiveChangeText extends ConsumerWidget {
  const _ActiveChangeText({
    required this.progress,
    this.label,
  });

  final String? label;
  final double progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox.square(
          dimension: kLoaderHeight,
          child: YaruCircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: kSpacingSmall),
          Text(
            label!,
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
  const _CancelActiveChangeButton({
    required this.onCancelPressed,
  });

  final void Function(WidgetRef ref)? onCancelPressed;

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
      onPressed: widget.onCancelPressed != null && !isPressed
          ? () {
              setState(() {
                isPressed = true;
                widget.onCancelPressed?.call(ref);
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
