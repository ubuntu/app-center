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
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/connectivity_notifier.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/explore/explore_error_page.dart';
import 'package:software/app/explore/explore_header.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:software/app/explore/offline_page.dart';
import 'package:software/app/explore/search_page.dart';
import 'package:software/app/explore/start_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, required this.section});

  final SnapSection section;

  static Widget createTitle(BuildContext context, SnapSection snapSection) =>
      Text(
        snapSection == SnapSection.all
            ? context.l10n.explorePageTitle
            : snapSection.localize(context.l10n),
      );

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
    required SnapSection snapSection,
  }) {
    return Icon(snapSection.getIcon(selected));
  }

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  StreamSubscription<bool>? _sidebarEventListener;
  @override
  void initState() {
    super.initState();
    final model = context.read<ExploreModel>();
    _sidebarEventListener = context.read<AppModel>().sidebarEvents.listen((_) {
      model.setSearchQuery('');
      model.setSelectedSection(widget.section);
    });
    final connectivity = context.read<ConnectivityNotifier>();
    connectivity.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      model.setSelectedSection(widget.section);
      model.setSearchQuery('');
    });
  }

  @override
  void dispose() {
    _sidebarEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityNotifier>();
    final showSearchPage = context.select((ExploreModel m) => m.showSearchPage);
    final searchQuery = context.select((ExploreModel m) => m.searchQuery);
    final setSearchQuery = context.read<ExploreModel>().setSearchQuery;
    final startPageApps = context.read<ExploreModel>().startPageApps;
    context.select((ExploreModel m) => m.startPageAppsChanged);
    final selectedAppFormats =
        context.select((ExploreModel m) => m.selectedAppFormats);
    final enabledAppFormats =
        context.select((ExploreModel m) => m.enabledAppFormats);
    final selectedSection =
        context.select((ExploreModel m) => m.selectedSection);
    final setSelectedSection =
        context.select((ExploreModel m) => m.setSelectedSection);
    final handleAppFormat =
        context.select((ExploreModel m) => m.handleAppFormat);

    final showSnap = context.select(
      (ExploreModel m) => m.selectedAppFormats.contains(AppFormat.snap),
    );
    final showPackageKit = context.select(
      (ExploreModel m) => m.selectedAppFormats.contains(AppFormat.packageKit),
    );

    final searchResult = context.select((ExploreModel m) => m.searchResult);
    final search = context.select((ExploreModel m) => m.search);
    final errorMessage = context.select((AppModel m) => m.errorMessage);

    final topRatedApps = context.watch<ExploreModel>().topRatedApps;

    return Scaffold(
      appBar: YaruWindowTitleBar(
        leading: const SizedBox(width: kLeadingGap),
        title: SearchField(
          key: ValueKey(
            '$showSearchPage${ModalRoute.of(context)?.isCurrent ?? searchQuery}',
          ),
          searchQuery: searchQuery,
          onChanged: (value) {
            setSearchQuery(value);
            search();
          },
          hintText: widget.section == SnapSection.all
              ? context.l10n.searchHintAppStore
              : '${context.l10n.searchHint}: ${widget.section.localize(context.l10n)}',
        ),
      ),
      body: !connectivity.isOnline
          ? const OfflinePage()
          : errorMessage != null && errorMessage.isNotEmpty
              ? const ExploreErrorPage()
              : (showSearchPage
                  ? SearchPage(
                      searchResult: searchResult,
                      showPackageKit: showPackageKit,
                      showSnap: showSnap,
                      header: ExploreHeader(
                        selectedSection: selectedSection,
                        enabledAppFormats: enabledAppFormats,
                        selectedAppFormats: selectedAppFormats,
                        handleAppFormat: (appFormat) {
                          handleAppFormat(appFormat);
                          search();
                        },
                        setSelectedSection: (value) {
                          setSelectedSection(value);
                          search();
                        },
                      ),
                    )
                  : StartPage(
                      topRatedApps: topRatedApps ?? [],
                      apps: startPageApps[widget.section],
                      snapSection: widget.section,
                      gameApps: widget.section == SnapSection.all
                          ? startPageApps[SnapSection.games]
                          : null,
                    )),
    );
  }
}
