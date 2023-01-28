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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/app_model.dart';
import 'package:software/app/common/connectivity_notifier.dart';
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
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  static Widget create(
    BuildContext context, [
    String? errorMessage,
  ]) {
    return ChangeNotifierProvider(
      create: (_) => ExploreModel(
        getService<AppstreamService>(),
        getService<SnapService>(),
        getService<PackageService>(),
        errorMessage,
      )..init(),
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
  StreamSubscription<bool>? _sidebarEventListener;
  @override
  void initState() {
    super.initState();
    final model = context.read<ExploreModel>();
    _sidebarEventListener = context
        .read<AppModel>()
        .sidebarEvents
        .listen((_) => model.setSearchQuery(''));
    final connectivity = context.read<ConnectivityNotifier>();
    connectivity.init();
  }

  @override
  void dispose() {
    _sidebarEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityNotifier>();
    final showErrorPage = context.select((ExploreModel m) => m.showErrorPage);
    final showSearchPage = context.select((ExploreModel m) => m.showSearchPage);
    final searchQuery = context.select((ExploreModel m) => m.searchQuery);
    final setSearchQuery = context.read<ExploreModel>().setSearchQuery;

    return Scaffold(
      appBar: YaruWindowTitleBar(
        title: SearchField(
          key: ValueKey(showSearchPage),
          searchQuery: searchQuery,
          onChanged: setSearchQuery,
        ),
      ),
      body: !connectivity.isOnline
          ? const OfflinePage()
          : showErrorPage
              ? const ExploreErrorPage()
              : (showSearchPage ? const SearchPage() : const StartPage()),
    );
  }
}
