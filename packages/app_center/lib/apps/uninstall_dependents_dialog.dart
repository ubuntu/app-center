import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

const _kItemExtent = 28.0;
const _kMaxVisibleItems = 6;
const _kScrollbarGap = 12.0;
// Dialog content width: the dialog maximum minus its icon and the gap after it.
const _kListWidth = kMaxDialogWidth - 48 - 16;

/// A fixed-size list of package names. When it overflows, the scrollbar is
/// always shown and the first hidden row is cut in half, so it's clear that
/// there is more to scroll to.
class _DependentsList extends StatefulWidget {
  const _DependentsList(this.names);

  final List<String> names;

  @override
  State<_DependentsList> createState() => _DependentsListState();
}

class _DependentsListState extends State<_DependentsList> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overflows = widget.names.length > _kMaxVisibleItems;
    final visibleRows = overflows
        ? _kMaxVisibleItems + 0.5
        : widget.names.length.toDouble();
    // The dialog measures its content's intrinsic size, which a viewport can't
    // provide, so the list gets an explicit size.
    return SizedBox(
      width: _kListWidth,
      height: visibleRows * _kItemExtent,
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: overflows,
        child: SelectionArea(
          child: ListView(
            controller: _controller,
            itemExtent: _kItemExtent,
            padding: EdgeInsets.only(right: overflows ? _kScrollbarGap : 0),
            children: [
              for (final name in widget.names)
                Row(
                  children: [
                    const ExcludeSemantics(
                      child: SelectionContainer.disabled(child: Text('•')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks the user to confirm uninstalling [appName] along with the [dependents]
/// that need it. Returns whether the uninstall should go ahead.
Future<bool> confirmUninstallWithDependents(
  BuildContext context, {
  required String appName,
  required List<String> dependents,
}) async {
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  final confirmed = await showYaruInfoDialog<bool>(
    context: context,
    type: YaruInfoType.warning,
    actions: [
      DialogAction(value: false, label: l10n.snapActionCancelLabel),
      DialogAction(value: true, label: l10n.snapActionRemoveLabel),
    ],
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.uninstallDependentsTitle(appName),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(l10n.uninstallDependentsMessage(appName)),
        const SizedBox(height: 8),
        _DependentsList(dependents),
      ],
    ),
  );
  return confirmed ?? false;
}
