import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/search_field.dart';
import 'package:software/store_app/explore/search_page.dart';
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
        getService<PackageKitClient>(),
      ),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.explorePageTitle);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return Scaffold(
      appBar: AppBar(
        title: !model.searchActive
            ? YaruRoundToggleButton(
                selected: model.searchActive,
                iconData: YaruIcons.search,
                onPressed: () => model.searchActive = !model.searchActive,
              )
            : null,
        flexibleSpace: !model.searchActive ? null : const SearchField(),
      ),
      body: Column(
        children: [
          if ((model.selectedSection == SnapSection.featured ||
                  model.selectedSection == SnapSection.all) &&
              model.searchQuery.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: SnapBannerCarousel(
                snapSection: SnapSection.featured,
                height: 220,
              ),
            ),
          if (model.searchQuery.isEmpty &&
              model.sectionNameToSnapsMap.isNotEmpty)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: (model.selectedSection == SnapSection.featured ||
                          model.selectedSection == SnapSection.all)
                      ? 0
                      : 20,
                ),
                child: SectionBannerGrid(snapSection: model.selectedSection),
              ),
            ),
          if (model.errorMessage.isNotEmpty)
            _ErrorPage(errorMessage: model.errorMessage),
          if (model.searchQuery.isNotEmpty)
            const Expanded(
              child: SearchPage(),
            )
        ],
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final String errorMessage;

  const _ErrorPage({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return YaruPage(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              errorMessage,
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
