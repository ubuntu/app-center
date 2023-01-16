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
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/constants.dart';

class SectionGrid extends StatelessWidget {
  const SectionGrid({
    Key? key,
    required this.snaps,
    this.animateBanners = false,
    this.padding,
    this.initSection = true,
    this.ignoreScrolling = true,
    this.take = 10,
    this.skip = 0,
  }) : super(key: key);

  final List<Snap> snaps;
  final int take;
  final int skip;
  final bool animateBanners;
  final EdgeInsets? padding;
  final bool initSection;
  final bool ignoreScrolling;

  @override
  Widget build(BuildContext context) {
    if (snaps.isEmpty) return const SizedBox();

    final snapsMod = snaps.take(take).toList().skip(skip);

    return GridView.builder(
      physics: ignoreScrolling ? const NeverScrollableScrollPhysics() : null,
      padding: padding ??
          const EdgeInsets.only(
            bottom: kPagePadding - 5,
            left: kPagePadding - 5,
            right: kPagePadding - 5,
          ),
      shrinkWrap: true,
      gridDelegate: kGridDelegate,
      itemCount: snapsMod.length,
      itemBuilder: (context, index) {
        final snap = snapsMod.elementAt(index);

        return AppBanner(
          appFinding: MapEntry<String, AppFinding>(
            snap.name,
            AppFinding(
              snap: snap,
              rating: 4.5,
              totalRatings: 234,
            ),
          ),
          showSnap: true,
          showPackageKit: false,
        );
      },
    );
  }
}
