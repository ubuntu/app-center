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
import 'package:software/app/common/search_field.dart';
import 'package:software/app/explore/explore_error_page.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:software/app/explore/offline_page.dart';
import 'package:software/app/explore/search_page.dart';
import 'package:software/app/explore/start_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(
    BuildContext context,
    bool online, [
    String? errorMessage,
  ]) {
    if (!online) return const OfflinePage();
    return ChangeNotifierProvider(
      create: (_) => ExploreModel(
        getService<AppstreamService>(),
        getService<SnapService>(),
        getService<PackageService>(),
        errorMessage,
      ),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.explorePageTitle);

  static Widget createIcon(
    BuildContext context,
    bool selected,
  ) =>
      selected
          ? const Icon(YaruIcons.compass_filled)
          : const Icon(YaruIcons.compass);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    context.read<ExploreModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final showErrorPage = context.select((ExploreModel m) => m.showErrorPage);
    final showSearchPage = context.select((ExploreModel m) => m.showSearchPage);
    final searchQuery = context.select((ExploreModel m) => m.searchQuery);
    final setSearchQuery = context.read<ExploreModel>().setSearchQuery;

    final searchField = SearchField(
      searchQuery: searchQuery,
      onChanged: setSearchQuery,
    );

    if (showErrorPage) {
      return const ExploreErrorPage();
    } else {
      return Navigator(
        pages: [
          MaterialPage(
            child: StartPage(
              searchField: searchField,
            ),
          ),
          if (showSearchPage)
            MaterialPage(
              child: SearchPage(
                searchField: searchField,
              ),
            )
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    }
  }
}
