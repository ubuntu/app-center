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
import 'package:software/store_app/common/app_format.dart';
import 'package:software/store_app/common/search_field.dart';
import 'package:software/store_app/installed/installed_header.dart';
import 'package:software/store_app/installed/installed_model.dart';
import 'package:software/store_app/installed/installed_packages_page.dart';
import 'package:software/store_app/installed/installed_snaps_page.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class InstalledPage extends StatelessWidget {
  const InstalledPage({
    Key? key,
    this.onTabTapped,
    this.initalTabIndex = 0,
  }) : super(key: key);

  final Function(int)? onTabTapped;
  final int initalTabIndex;

  static Widget create(
    BuildContext context,
    Function(int)? onTabTapped,
    int tabIndex,
  ) {
    return ChangeNotifierProvider(
      create: (context) => InstalledModel(
        getService<PackageService>(),
        getService<SnapService>(),
      ),
      child: InstalledPage(
        onTabTapped: onTabTapped,
        initalTabIndex: tabIndex,
      ),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.installed);

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select((InstalledModel m) => m.searchQuery);
    final appFormat = context.select((InstalledModel m) => m.appFormat);
    final setSearchQuery =
        context.select((InstalledModel m) => m.setSearchQuery);

    final page = Column(
      children: [
        const InstalledHeader(),
        if (appFormat == AppFormat.snap)
          const Expanded(child: InstalledSnapsPage())
        else if (appFormat == AppFormat.packageKit)
          const Expanded(child: InstalledPackagesPage()),
      ],
    );

    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: SearchField(
                searchQuery: searchQuery ?? '',
                onChanged: (v) => setSearchQuery(v),
                clear: () {
                  setSearchQuery('');
                },
              ),
            ),
            body: page,
          ),
        ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}
