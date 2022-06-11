import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class FilterBar extends StatefulWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return SizedBox(
      width: 1000,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.hovered) ? true : false,
          ),
        ),
        child: Scrollbar(
          controller: _controller,
          child: ListView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              for (final section in model.sortedFilters)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    left: 5,
                    right: 5,
                  ),
                  child: YaruRoundToggleButton(
                    size: 36,
                    tooltip: section.localize(context.l10n),
                    onPressed: () => model.setFilter(snapSections: [section]),
                    selected: model.filters[section]!,
                    iconData: snapSectionToIcon[section]!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
