import 'package:app_center/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:yaru/yaru.dart';

class AppPageSection extends StatefulWidget {
  const AppPageSection({
    required this.header,
    required this.child,
    super.key,
  });

  final Widget header;
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
      header: widget.header,
      expandIcon: Icon(
        YaruIcons.pan_end,
        semanticLabel:
            expanded ? l10n.sectionCollapseLabel : l10n.sectionExpandLabel,
      ),
      onChange: (expanded) => setState(() {
        this.expanded = expanded;
      }),
      child: widget.child,
    );
  }
}
