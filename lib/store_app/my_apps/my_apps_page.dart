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
import 'package:software/store_app/common/package_page.dart';
import 'package:software/store_app/common/snap_page.dart';
import 'package:software/store_app/my_apps/my_apps_model.dart';
import 'package:software/store_app/my_apps/my_apps_search_field.dart';
import 'package:software/store_app/my_apps/my_packages_page.dart';
import 'package:software/store_app/my_apps/my_snaps_page.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatelessWidget {
  const MyAppsPage({
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
      create: (context) => MyAppsModel(
        getService<PackageService>(),
        getService<SnapService>(),
      ),
      child: MyAppsPage(
        onTabTapped: onTabTapped,
        initalTabIndex: tabIndex,
      ),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.myAppsPageTitle);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyAppsModel>();
    return Navigator(
      pages: [
        MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              flexibleSpace: MyAppSearchField(
                searchQuery: model.searchQuery ?? '',
                onChanged: (v) => model.searchQuery = v,
                clear: () {
                  model.searchQuery = '';
                },
              ),
            ),
            body: YaruTabbedPage(
              onTap: onTabTapped,
              initialIndex: initalTabIndex,
              tabIcons: const [
                YaruIcons.package_snap,
                YaruIcons.package_deb,
              ],
              tabTitles: [
                context.l10n.snapPackages,
                context.l10n.debianPackages,
              ],
              // ignore: prefer_const_literals_to_create_immutables
              views: [
                // ignore: prefer_const_constructors
                MySnapsPage(key: ValueKey('snaps')),
                // ignore: prefer_const_constructors
                MyPackagesPage(
                  // ignore: prefer_const_constructors
                  key: ValueKey('packages'),
                ),
              ],
            ),
          ),
        ),
        if (model.selectedSnap != null && model.selectedPackage == null)
          MaterialPage(
            key: ObjectKey(model.selectedSnap),
            child: SnapPage.create(
              context: context,
              huskSnapName: model.selectedSnap!.name,
              onPop: model.clearSelection,
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
