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
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/common/snap/snap_utils.dart';
import 'package:software/app/explore/explore_model.dart';

class SectionGrid extends StatelessWidget {
  const SectionGrid({
    Key? key,
    required this.snapSection,
    this.animateBanners = false,
    this.padding,
    this.initSection = true,
    this.ignoreScrolling = true,
    required this.initialAmount,
  }) : super(key: key);

  final SnapSection snapSection;
  final bool animateBanners;
  final EdgeInsets? padding;
  final bool initSection;
  final int initialAmount;
  final bool ignoreScrolling;

  @override
  Widget build(BuildContext context) {
    final snaps = context.select((ExploreModel m) {
      return m.sectionNameToSnapsMap[snapSection]?.take(initialAmount).toList();
    });
    if (snaps == null || snaps.isEmpty) return const SizedBox();
    final storeSnapSort = context.select((ExploreModel m) => m.storeSnapSort);
    // TODO: get real ratings from backend
    final fakeRating = context.select((ExploreModel m) => m.fakeRating());
    final totalRatings =
        context.select((ExploreModel m) => m.fakeTotalRatings());

    sortStoreSnaps(storeSnapSort: storeSnapSort, snaps: snaps);

    return GridView.builder(
      physics: ignoreScrolling ? const NeverScrollableScrollPhysics() : null,
      padding:
          padding ?? const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      shrinkWrap: true,
      gridDelegate: kGridDelegate,
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps.elementAt(index);

        return AppBanner(
          appFinding: MapEntry<String, AppFinding>(
            snap.name,
            AppFinding(
              snap: snap,
              rating: fakeRating,
              totalRatings: totalRatings,
            ),
          ),
          showSnap: true,
          showPackageKit: false,
        );
      },
    );
  }
}
