import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ActiveChangeStatus extends StatelessWidget {
  const ActiveChangeStatus({
    required this.onCancelPressed,
    required this.progress,
    this.actionLabel,
    this.appName,
    super.key,
  });

  final void Function()? onCancelPressed;
  final double progress;
  final String? actionLabel;

  /// Optional app name used to build an accessible label that identifies
  /// which app this status/cancel control applies to (e.g. "Cancel Update
  /// for Firefox" instead of just "Cancel"). When null, the default
  /// semantics of the underlying widgets are used.
  final String? appName;

  @override
  Widget build(BuildContext context) {
    final hasCustomLabel = appName != null && actionLabel != null;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        hasCustomLabel
            ? ExcludeSemantics(
                child: _ActiveChangeText(
                  label: actionLabel,
                  progress: progress,
                ),
              )
            : _ActiveChangeText(
                label: actionLabel,
                progress: progress,
              ),
        _CancelActiveChangeButton(
          onCancelPressed: onCancelPressed,
          hideDefaultLabel: hasCustomLabel,
        ),
      ].separatedBy(const SizedBox(width: kSpacing)),
    );

    if (!hasCustomLabel) {
      return row;
    }

    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.managePageCancelActionSemanticLabel(
        actionLabel!,
        appName!,
      ),
      child: row,
    );
  }
}

class _ActiveChangeText extends StatelessWidget {
  const _ActiveChangeText({
    required this.progress,
    this.label,
  });

  final String? label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toStringAsFixed(0);
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

//
class _CancelActiveChangeButton extends StatefulWidget {
  const _CancelActiveChangeButton({
    required this.onCancelPressed,
    this.hideDefaultLabel = false,
  });

  final void Function()? onCancelPressed;

  /// When true, hides this button's own "Cancel" text from the
  /// accessibility tree because an ancestor [Semantics] widget already
  /// supplies a more descriptive composite label (e.g. "Cancel Update for
  /// Firefox"). The button's native focus/tap semantics are preserved
  /// either way.
  final bool hideDefaultLabel;

  @override
  State<StatefulWidget> createState() => ActiveChangeButtonState();
}

class ActiveChangeButtonState extends State<_CancelActiveChangeButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Text(
      l10n.snapActionCancelLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    return OutlinedButton(
      onPressed: widget.onCancelPressed != null && !isPressed
          ? () {
              setState(() {
                isPressed = true;
                widget.onCancelPressed?.call();
              });
            }
          : null,
      child: widget.hideDefaultLabel ? ExcludeSemantics(child: text) : text,
    );
  }
}
