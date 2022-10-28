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
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap/snap_page.dart';
import 'package:software/store_app/common/snap/snap_section.dart';
import 'package:software/store_app/explore/color_banner.dart';
import 'package:software/store_app/explore/explore_model.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    final snaps = <SnapSection, Snap>{};

    for (var snapEntry in model.sectionNameToSnapsMap.entries) {
      for (int i = 0; i < snapEntry.value.length; i++) {
        if (i < 30 && snapEntry.key != SnapSection.featured) {
          snaps.putIfAbsent(snapEntry.key, () => snapEntry.value[i]);
        }
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 200,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        maxCrossAxisExtent: 700,
      ),
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snapEntry = snaps.entries.elementAt(index);
        final snap = snapEntry.value;
        final section = snapEntry.key;

        return ColorBanner.create(
          context: context,
          snap: snap,
          sectionName: section == SnapSection.all
              ? SnapSection.featured.localize(context.l10n)
              : section.localize(context.l10n),
          onTap: () => SnapPage.push(context, snap),
        );
      },
    );
  }
}
