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

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/installed/installed_header.dart';
import 'package:software/app/installed/installed_model.dart';
import 'package:software/app/installed/installed_packages_page.dart';
import 'package:software/app/installed/installed_snaps_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class InstalledPage extends StatelessWidget {
  const InstalledPage({Key? key}) : super(key: key);

  static Widget create(
    BuildContext context,
  ) {
    return ChangeNotifierProvider(
      create: (context) => InstalledModel(
        getService<PackageService>(),
        getService<SnapService>(),
      )..init(),
      child: const InstalledPage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.installed);

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
    int? badgeCount,
    bool? processing,
  }) {
    if (badgeCount != null && badgeCount > 0) {
      return _InstalledPageIcon(count: badgeCount);
    }
    return selected
        ? const Icon(YaruIcons.ok_filled)
        : const Icon(YaruIcons.ok);
  }

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

    return Scaffold(
      appBar: YaruWindowTitleBar(
        title: SearchField(
          autofocus: false,
          searchQuery: searchQuery ?? '',
          onChanged: setSearchQuery,
        ),
      ),
      body: page,
    );
  }
}

class _InstalledPageIcon extends StatelessWidget {
  // ignore: unused_element
  const _InstalledPageIcon({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Badge(
      badgeColor: Theme.of(context).primaryColor,
      badgeContent: Text(
        count.toString(),
        style: badgeTextStyle,
      ),
      child: const IndeterminateCircularProgressIcon(),
    );
  }
}
