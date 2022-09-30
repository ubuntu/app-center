/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/store_app/common/offline_page.dart';
import 'package:software/store_app/common/package_page.dart';
import 'package:software/store_app/common/snap_page.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/search_field.dart';
import 'package:software/store_app/explore/search_page.dart';
import 'package:software/store_app/explore/section_banner_grid.dart';
import 'package:software/store_app/explore/start_page.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context, bool online) {
    if (!online) return const OfflinePage();
    return ChangeNotifierProvider(
      create: (_) => ExploreModel(
        getService<SnapService>(),
        getService<PackageService>(),
      ),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.explorePageTitle);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            floatingActionButton: model.selectedSection != SnapSection.all &&
                    model.searchQuery.isEmpty
                ? FloatingActionButton.extended(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : const Color.fromARGB(255, 75, 75, 75),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    elevation: 0,
                    heroTag: 'more',
                    onPressed: () {
                      model.appResultAmount += 5;
                      _controller.animateTo(
                        _controller.position.maxScrollExtent + 5 * 120,
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    label: Text(context.l10n.showMore),
                  )
                : null,
            appBar: AppBar(
              flexibleSpace: const SearchField(),
            ),
            body: model.showErrorPage
                ? _ErrorPage(errorMessage: model.errorMessage)
                : model.showSearchPage
                    ? const SearchPage()
                    : model.showStartPage
                        ? const StartPage()
                        : SectionBannerGrid(
                            snapSection: model.selectedSection,
                            controller: _controller,
                          ),
          ),
        ),
        if (model.selectedSnap != null && model.selectedPackage == null)
          MaterialPage(
            key: ObjectKey(model.selectedSnap),
            child: SnapPage.create(
              context: context,
              huskSnapName: model.selectedSnap!.name,
              onPop: () => model.selectedSnap = null,
            ),
          ),
        if (model.selectedPackage != null && model.selectedSnap == null)
          MaterialPage(
            key: ObjectKey(model.selectedSnap),
            child: PackagePage.create(
              context: context,
              id: model.selectedPackage!,
              installedId: model.selectedPackage!,
              onPop: model.clearSelection,
            ),
          ),
      ],
      onPopPage: (route, result) => route.didPop(result),
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
