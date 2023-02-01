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
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/explore/explore_error_page.dart';
import 'package:software/app/explore/explore_header.dart';
import 'package:software/app/explore/offline_page.dart';
import 'package:software/app/explore/search_page.dart';
import 'package:software/app/explore/start_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    super.key,
  });

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
    final model = context.read<AppModel>();
    _sidebarEventListener = model.sidebarEvents.listen((_) {
      model.setSearchActive(false);
    });
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
    final selectedAppFormats =
        context.select((AppModel m) => m.selectedAppFormats);
    final enabledAppFormats =
        context.select((AppModel m) => m.enabledAppFormats);
    final selectedSection = context.select((AppModel m) => m.selectedSection);
    final setSelectedSection =
        context.select((AppModel m) => m.setSelectedSection);
    final handleAppFormat = context.select((AppModel m) => m.handleAppFormat);
    final showSnap = context.select(
      (AppModel m) => m.selectedAppFormats.contains(AppFormat.snap),
    );
    final showPackageKit = context.select(
      (AppModel m) => m.selectedAppFormats.contains(AppFormat.packageKit),
    );
    final searchResult = context.select((AppModel m) => m.searchResult);

    final errorMessage = context.select((AppModel m) => m.errorMessage);
    final sectionSnapsAll = context.select((AppModel m) {
      return m.sectionNameToSnapsMap[SnapSection.all];
    });
    final search = context.select((AppModel m) => m.search);
    final searchActive = context.select((AppModel m) => m.searchActive);

    return !connectivity.isOnline
        ? const OfflinePage()
        : errorMessage != null && errorMessage.isNotEmpty
            ? ExploreErrorPage(
                errorMessage: errorMessage,
              )
            : searchActive == true
                ? SearchPage(
                    searchResult: searchResult,
                    showPackageKit: showPackageKit,
                    showSnap: showSnap,
                    header: ExploreHeader(
                      selectedSection: selectedSection,
                      selectedAppFormats: selectedAppFormats,
                      enabledAppFormats: enabledAppFormats,
                      setSelectedSection: (value) {
                        setSelectedSection(value);
                        search();
                      },
                      handleAppFormat: (appFormat) {
                        handleAppFormat(appFormat);
                        search();
                      },
                    ),
                  )
                : StartPage(
                    snaps: sectionSnapsAll,
                    snapSection: SnapSection.all,
                  );
  }
}
