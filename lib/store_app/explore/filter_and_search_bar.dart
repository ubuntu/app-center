import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/search_field.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class FilterAndSearchBar extends StatefulWidget {
  const FilterAndSearchBar({Key? key}) : super(key: key);

  @override
  State<FilterAndSearchBar> createState() => _FilterAndSearchBarState();
}

class _FilterAndSearchBarState extends State<FilterAndSearchBar> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: YaruRoundToggleButton(
                size: 36,
                onPressed: () => model.searchActive = !model.searchActive,
                selected: model.searchActive,
                iconData: YaruIcons.search,
              ),
            ),
            model.searchActive
                ? const Expanded(child: SearchField())
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: SizedBox(
                        height: 36,
                        child: ListView(
                          controller: _controller,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          children: [
                            for (final section in model.sortedFilters)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: YaruRoundToggleButton(
                                  size: 36,
                                  tooltip: section.localize(context.l10n),
                                  onPressed: () =>
                                      model.setFilter(snapSections: [section]),
                                  selected: model.filters[section]!,
                                  iconData: snapSectionToIcon[section]!,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
