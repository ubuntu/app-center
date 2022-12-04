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
import 'package:software/services/appstream_service.dart';
import 'package:software/services/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/store_app/explore/explore_header.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/offline_page.dart';
import 'package:software/store_app/common/search_field.dart';
import 'package:software/store_app/explore/search_page.dart';
import 'package:software/store_app/explore/start_page.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final errorMessage = context.select((ExploreModel m) => m.errorMessage);
    final showErrorPage = context.select((ExploreModel m) => m.showErrorPage);
    final showSearchPage = context.select((ExploreModel m) => m.showSearchPage);
    final model = context.watch<ExploreModel>();
    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: SearchField(
                searchQuery: model.searchQuery,
                onChanged: (value) => model.searchQuery = value,
                clear: () => model.searchQuery = '',
              ),
            ),
            body: Column(
              children: [
                const ExploreHeader(),
                Expanded(
                  child: showErrorPage
                      ? _ErrorPage(errorMessage: errorMessage!)
                      : showSearchPage
                          ? const SearchPage()
                          : StartPage(screenSize: screenSize),
                )
              ],
            ),
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
    return ListView(
      padding: const EdgeInsets.all(kYaruPagePadding),
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
