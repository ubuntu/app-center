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
import 'package:snapd/snapd.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/loading_banner_grid.dart';
import 'package:software/store_app/common/snap/snap_page.dart';
import 'package:software/store_app/common/updates_splash_screen.dart';
import 'package:software/store_app/installed/installed_model.dart';
import 'package:software/store_app/updates/no_updates_page.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class InstalledSnapsPage extends StatefulWidget {
  const InstalledSnapsPage({Key? key}) : super(key: key);
  @override
  State<InstalledSnapsPage> createState() => _InstalledSnapsPageState();
}

class _InstalledSnapsPageState extends State<InstalledSnapsPage> {
  @override
  void initState() {
    context.read<InstalledModel>().init();
    super.initState();
  }

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

    if (model.localSnaps.isEmpty) {
      return model.loadSnapsWithUpdates
          ? const NoUpdatesPage(
              expand: false,
            )
          : const LoadingBannerGrid();
    }

    return model.busy
        ? const UpdatesSplashScreen(
            icon: YaruIcons.snapcraft,
            expanded: false,
          )
        : _MySnapsGrid(snaps: snaps);
  }
}

class _MySnapsGrid extends StatelessWidget {
  // ignore: unused_element
  const _MySnapsGrid({super.key, required this.snaps});

  final List<Snap> snaps;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: kGridPadding,
      gridDelegate: kGridDelegate,
      shrinkWrap: true,
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps.elementAt(index);
        return YaruBanner(
          title: Text(
            snap.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            snap.summary,
            overflow: TextOverflow.ellipsis,
          ),
          icon: Padding(
            padding: kIconPadding,
            child: AppIcon(
              iconUrl: snap.iconUrl,
            ),
          ),
          onTap: () => SnapPage.push(context, snap),
        );
      },
    );
  }
}
