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
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/loading_banner_grid.dart';

class SectionGrid extends StatelessWidget {
  const SectionGrid({
    super.key,
    required this.apps,
    this.animateBanners = false,
    this.padding,
    this.initSection = true,
    this.ignoreScrolling = true,
    this.take = 10,
    this.skip = 0,
  });

  final List<AppFinding?>? apps;
  final int take;
  final int skip;
  final bool animateBanners;
  final EdgeInsets? padding;
  final bool initSection;
  final bool ignoreScrolling;

  @override
  Widget build(BuildContext context) {
    if (apps == null ||
        apps!.isEmpty ||
        apps!.any((app) => app == null) ||
        apps!.any((app) => app!.snap == null)) return const LoadingBannerGrid();

    final appsMod = apps!.take(take).toList().skip(skip);

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
      itemCount: appsMod.length,
      itemBuilder: (context, index) {
        final app = appsMod.elementAt(index);

        return AppBanner(
          appFinding: MapEntry<String, AppFinding>(
            app!.snap!.title ?? '',
            app,
          ),
          showSnap: true,
          showPackageKit: true,
        );
      },
    );
  }
}
