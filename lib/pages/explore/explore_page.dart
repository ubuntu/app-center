import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_section.dart';
import 'package:software/pages/explore/app_banner_carousel.dart';
import 'package:software/pages/explore/app_banner_grid.dart';
import 'package:software/pages/explore/app_grid.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final client = getService<SnapdClient>();
    final connectivity = getService<Connectivity>();
    return ChangeNotifierProvider(
      create: (_) => AppsModel(client, connectivity),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.explorePageTitle);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                YaruRoundToggleButton(
                  onPressed: () => model.searchActive = !model.searchActive,
                  selected: model.searchActive,
                  iconData: YaruIcons.search,
                ),
                if (!model.searchActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: YaruRoundToggleButton(
                      onPressed: () => model.exploreMode = !model.exploreMode,
                      selected: model.exploreMode,
                      iconData: YaruIcons.image,
                    ),
                  ),
                if (!model.searchActive)
                  YaruRoundToggleButton(
                    onPressed: () => model.exploreMode = !model.exploreMode,
                    selected: !model.exploreMode,
                    iconData: YaruIcons.format_unordered_list,
                  ),
                if (!model.exploreMode || model.searchActive)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: SizedBox(
                      height: 40,
                      child: VerticalDivider(
                        width: 20,
                        thickness: 0.5,
                      ),
                    ),
                  ),
                model.searchActive
                    ? const Expanded(child: _SearchField())
                    : Expanded(
                        child: !model.exploreMode
                            ? const _FilterBar()
                            : const SizedBox()),
              ],
            ),
          ),
        ),
        Expanded(
          child: YaruPage(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            children: [
              if (width < 1000 && !model.searchActive && model.exploreMode)
                const AppBannerCarousel(),
              if (model.searchActive)
                const SizedBox(
                  height: 20,
                ),
              if (model.searchActive)
                AppGrid(
                  name: model.searchQuery,
                  findByQuery: true,
                ),
              if (!model.searchActive && !model.exploreMode)
                for (int i = 0; i < model.filters.entries.length; i++)
                  if (model.filters.entries.elementAt(i).value == true)
                    AppGrid(
                      appendBottomDivier: true,
                      name: model.filters.entries.elementAt(i).key.title,
                      headline: model.filters.entries
                          .elementAt(i)
                          .key
                          .localize(context.l10n),
                      findByQuery: false,
                    ),
              if (!model.searchActive && model.exploreMode)
                const AppBannerGrid(snapSection: SnapSection.featured),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({Key? key}) : super(key: key);

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: _controller,
        onChanged: (value) => model.searchQuery = value,
        autofocus: true,
        decoration: InputDecoration(
          prefixIcon: model.searchQuery == ''
              ? null
              : IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    model.searchQuery = '';
                    _controller.text = '';
                  },
                  icon: const Icon(YaruIcons.edit_clear)),
          isDense: false,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}

class _FilterBar extends StatefulWidget {
  const _FilterBar({Key? key}) : super(key: key);

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();
    return SizedBox(
      width: 1000,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
            thumbVisibility: MaterialStateProperty.resolveWith((states) =>
                states.contains(MaterialState.hovered) ? true : false)),
        child: Scrollbar(
          controller: _controller,
          child: ListView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              for (final section in model.selectedFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: YaruRoundToggleButton(
                      tooltip: section.localize(context.l10n),
                      onPressed: () => model.setFilter(snapSections: [section]),
                      selected: model.filters[section]!,
                      iconData: snapSectionToIcon[section]!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
