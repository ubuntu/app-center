import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/filter_bar.dart';
import 'package:software/store_app/explore/search_field.dart';
import 'package:software/store_app/explore/snap_banner_carousel.dart';
import 'package:software/store_app/explore/snap_tile_grid.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
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
    return Column(
      children: [
        const _HeaderBar(),
        Expanded(
          child: model.errorMessage.isNotEmpty
              ? const _ErrorPage()
              : model.exploreMode && !model.searchActive
                  ? const _ExploreModePage()
                  : const _GridViewPage(),
        ),
      ],
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({Key? key}) : super(key: key);

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
            if (!model.searchActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: YaruRoundToggleButton(
                  size: 36,
                  onPressed: () => model.exploreMode = !model.exploreMode,
                  selected: model.exploreMode,
                  iconData: YaruIcons.image,
                ),
              ),
            if (!model.searchActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: YaruRoundToggleButton(
                  size: 36,
                  onPressed: () => model.exploreMode = !model.exploreMode,
                  selected: !model.exploreMode,
                  iconData: YaruIcons.format_unordered_list,
                ),
              ),
            if (!model.exploreMode || model.searchActive)
              const SizedBox(
                height: 36,
                child: VerticalDivider(
                  width: 20,
                  thickness: 0.5,
                ),
              ),
            model.searchActive
                ? const Expanded(child: SearchField())
                : Expanded(
                    child: !model.exploreMode
                        ? const FilterBar()
                        : const SizedBox(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ExploreModePage extends StatelessWidget {
  const _ExploreModePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    final width = MediaQuery.of(context).size.width;

    return YaruPage(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SnapBannerCarousel(
          snapSection: SnapSection.featured,
        ),
        Row(
          children: [
            const Expanded(
              child: SnapBannerCarousel(
                snapSection: SnapSection.games,
                duration: Duration(seconds: 4),
              ),
            ),
            if (model.showTwoCarousels(width: width))
              const SizedBox(
                width: 20,
              ),
            if (model.showTwoCarousels(width: width))
              const Expanded(
                child: SnapBannerCarousel(
                  snapSection: SnapSection.development,
                  duration: Duration(seconds: 6),
                ),
              ),
            if (model.showThreeCarousels(width: width))
              const SizedBox(
                width: 20,
              ),
            if (model.showThreeCarousels(width: width))
              const Expanded(
                child: SnapBannerCarousel(
                  snapSection: SnapSection.art_and_design,
                  duration: Duration(seconds: 6),
                ),
              )
          ],
        ),
        const SnapBannerCarousel(
          snapSection: SnapSection.devices_and_iot,
          duration: Duration(seconds: 10),
        ),
        Row(
          children: [
            const Expanded(
              child: SnapBannerCarousel(
                snapSection: SnapSection.books_and_reference,
                duration: Duration(seconds: 4),
              ),
            ),
            if (model.showTwoCarousels(width: width))
              const SizedBox(
                width: 20,
              ),
            if (model.showTwoCarousels(width: width))
              const Expanded(
                child: SnapBannerCarousel(
                  snapSection: SnapSection.education,
                  duration: Duration(seconds: 6),
                ),
              ),
            if (model.showThreeCarousels(width: width))
              const SizedBox(
                width: 20,
              ),
            if (model.showThreeCarousels(width: width))
              const Expanded(
                child: SnapBannerCarousel(
                  snapSection: SnapSection.finance,
                  duration: Duration(seconds: 6),
                ),
              )
          ],
        ),
      ],
    );
  }
}

class _GridViewPage extends StatelessWidget {
  const _GridViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    return YaruPage(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (model.searchActive)
          const SizedBox(
            height: 20,
          ),
        if (model.searchActive)
          SnapTileGrid(
            name: model.searchQuery,
            findByQuery: true,
          ),
        if (!model.searchActive)
          for (int i = 0; i < model.filters.entries.length; i++)
            if (model.filters.entries.elementAt(i).value == true)
              SnapTileGrid(
                appendBottomDivier: true,
                name: model.filters.entries.elementAt(i).key.title,
                headline: model.filters.entries
                    .elementAt(i)
                    .key
                    .localize(context.l10n),
                findByQuery: false,
              ),
      ],
    );
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
