import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/filter_bar.dart';
import 'package:software/store_app/explore/search_field.dart';
import 'package:software/store_app/explore/search_list.dart';
import 'package:software/store_app/explore/section_banner_grid.dart';
import 'package:software/store_app/explore/snap_banner_carousel.dart';
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
              : !model.searchActive
                  ? const _ExploreModePage()
                  : const SearchList(),
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
            model.searchActive
                ? const Expanded(child: SearchField())
                : const Expanded(
                    child: FilterBar(),
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

    return YaruPage(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SnapBannerCarousel(
          snapSection: SnapSection.featured,
          height: 220,
        ),
        for (int i = 0; i < model.filters.entries.length; i++)
          if (model.filters.entries.elementAt(i).value == true)
            SectionBannerGrid(
              controller: ScrollController(),
              snapSection: model.filters.entries.elementAt(i).key,
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
