import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/offline_page.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/search_field.dart';
import 'package:software/store_app/explore/search_page.dart';
import 'package:software/store_app/explore/section_banner_grid.dart';
import 'package:software/store_app/explore/snap_banner_carousel.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context, bool online) {
    if (!online) return const OfflinePage();
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
        flexibleSpace: const SearchField(),
      ),
      body: model.showErrorPage
          ? _ErrorPage(errorMessage: model.errorMessage)
          : model.showSearchPage
              ? const SearchPage()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (model.showTopCarousel)
                        const SnapBannerCarousel(
                          snapSection: SnapSection.featured,
                          height: 220,
                        ),
                      if (model.showSectionBannerGrid)
                        SectionBannerGrid(
                          snapSection: model.selectedSection,
                        ),
                    ],
                  ),
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
