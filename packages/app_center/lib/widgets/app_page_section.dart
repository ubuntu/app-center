import 'package:app_center/l10n.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class AppPageSection extends StatefulWidget {
  const AppPageSection({
    required this.header,
    required this.child,
    super.key,
  });

  final String header;
  final Widget child;

  @override
  State<AppPageSection> createState() => _AppPageSectionState();
}

class _AppPageSectionState extends State<AppPageSection> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return YaruExpandable(
      expandButtonPosition: YaruExpandableButtonPosition.start,
      gapHeight: 24,
      isExpanded: expanded,
      header: Text(
        widget.header,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w500),
      ),
      expandIcon: Icon(
        YaruIcons.pan_end,
        semanticLabel: expanded
            ? l10n.sectionCollapseSemanticLabel(widget.header)
            : l10n.sectionExpandSemanticLabel(widget.header),
      ),
      onChange: (expanded) => setState(() {
        this.expanded = expanded;
      }),
      child: widget.child,
    );
  }
}
