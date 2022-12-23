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
import 'package:software/app/common/loading_banner_grid.dart';
import 'package:software/app/common/snap/snap_grid.dart';
import 'package:software/app/common/updates_splash_screen.dart';
import 'package:software/app/installed/installed_model.dart';
import 'package:software/app/common/error_page.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class InstalledSnapsPage extends StatefulWidget {
  const InstalledSnapsPage({Key? key}) : super(key: key);
  @override
  State<InstalledSnapsPage> createState() => _InstalledSnapsPageState();
}

class _InstalledSnapsPageState extends State<InstalledSnapsPage> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<InstalledModel>();
    final snaps = model.searchQuery == null
        ? model.localSnaps
        : model.localSnaps
            .where(
              (s) => s.name.startsWith(model.searchQuery!),
            )
            .toList();

    if (!SnapService.isSnapdInstalled) {
      return const ErrorPage(
        icon: YaruIcons.warning,
        message: 'Snapd is not installed on your system!',
      );
    } else if (model.localSnaps.isEmpty && !model.isLoadingSnapsCompleted) {
      return const LoadingBannerGrid();
    } else if (model.localSnaps.isEmpty && model.isLoadingSnapsCompleted) {
      return ErrorPage(
        icon: YaruIcons.warning,
        message: context.l10n.noSnapsInstalled,
      );
    }

    return model.busy
        ? const UpdatesSplashScreen(
            icon: YaruIcons.snapcraft,
            expanded: false,
          )
        : SnapGrid(snaps: snaps);
  }
}

