import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/filter_and_search_bar.dart';
import 'package:software/store_app/explore/search_page.dart';
import 'package:software/store_app/explore/section_banner_grid.dart';
import 'package:software/store_app/explore/snap_banner_carousel.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExploreModel(
        getService<SnapdClient>(),
      ),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.explorePageTitle);
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    if (model.errorMessage.isNotEmpty) return const _ErrorPage();
    return !model.searchActive
        ? Column(
            children: [
              const FilterAndSearchBar(),
              if (model.filters[SnapSection.featured] == true &&
                  model.sectionNameToSnapsMap.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SnapBannerCarousel(
                    snapSection: SnapSection.featured,
                    height: 220,
                  ),
                ),
              if (model.sectionNameToSnapsMap.isNotEmpty)
                Expanded(
                  child: YaruPage(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (int i = 0; i < model.filters.entries.length; i++)
                        if (model.filters.entries.elementAt(i).value == true)
                          SectionBannerGrid(
                            snapSection: model.filters.entries.elementAt(i).key,
                          ),
                    ],
                  ),
                )
            ],
          )
        : const SearchPage();
  }
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    return YaruPage(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              model.errorMessage,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        )
      ],
    );
  }
}
