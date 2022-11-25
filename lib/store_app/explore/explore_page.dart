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
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../l10n/l10n.dart';
import '../../services/package_service.dart';
import '../../services/snap_service.dart';
import '../common/snap/snap_section.dart';
import 'explore_header.dart';
import 'explore_model.dart';
import 'offline_page.dart';
import 'search_field.dart';
import 'search_page.dart';
import 'start_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

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
  @override
  void initState() {
    super.initState();
    final model = context.read<ExploreModel>();

    for (final section in SnapSection.values) {
      model.loadSection(section);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    final screenSize = MediaQuery.of(context).size;

    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: const SearchField(),
            ),
            body: Column(
              children: [
                const ExploreHeader(),
                Expanded(
                  child: model.showErrorPage
                      ? _ErrorPage(errorMessage: model.errorMessage)
                      : model.showSearchPage
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

  const _ErrorPage({required this.errorMessage});
  final String errorMessage;

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
