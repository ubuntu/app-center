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
import 'package:snapd/snapd.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/snap/snap_page.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapGrid extends StatelessWidget {
  const SnapGrid({super.key, required this.snaps});

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
        return YaruBanner.tile(
          surfaceTintColor: Theme.of(context).brightness == Brightness.light
              ? kBannerBgLight
              : kBannerBgDark,
          elevation: kBannerElevation,
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
