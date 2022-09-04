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
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/my_apps/my_packages_page.dart';
import 'package:software/store_app/my_apps/my_snaps_page.dart';
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
    return MyAppsPage(
      onTabTapped: onTabTapped,
      initalTabIndex: tabIndex,
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.myAppsPageTitle, textAlign: TextAlign.center);

  @override
  Widget build(BuildContext context) {
    return YaruTabbedPage(
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
      views: [
        MySnapsPage.create(context),
        MyPackagesPage.create(context),
      ],
    );
  }
}
