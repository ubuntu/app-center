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
import 'package:shimmer/shimmer.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/loading_banner_grid.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/explore/section_banner.dart';
import 'package:software/app/explore/section_grid.dart';
import 'package:software/snapx.dart';
import 'package:yaru_colors/yaru_colors.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    this.apps,
    required this.snapSection,
  });

  final List<AppFinding>? apps;
  final SnapSection snapSection;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late ScrollController _controller;
  late int _amount;

  @override
  void initState() {
    super.initState();

    _amount = 60;
    _controller = ScrollController();

    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        setState(() {
          _amount = _amount + 5;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 15),
      controller: _controller,
      child: Column(
        children: [
          _TeaserPage(
            snapSection: widget.snapSection,
            apps: widget.apps,
          ),
        ],
      ),
    );
  }
}

class _TeaserPage extends StatelessWidget {
  const _TeaserPage({
    required this.snapSection,
    this.apps,
  });

  final SnapSection snapSection;
  final List<AppFinding>? apps;

  @override
  Widget build(BuildContext context) {
    final appsWithIcons =
        apps?.where((app) => app.snap?.iconUrl != null).toList();
    Snap? bannerSnap;
    Snap? bannerSnap2;
    Snap? bannerSnap3;

    if (appsWithIcons != null && appsWithIcons.isNotEmpty) {
      bannerSnap = appsWithIcons.elementAt(0).snap;
      bannerSnap2 = appsWithIcons.elementAt(1).snap;
      bannerSnap3 = appsWithIcons.elementAt(2).snap;
    }
    if (bannerSnap == null || bannerSnap2 == null || bannerSnap3 == null) {
      return Column(
        children: const [
          _LoadingSectionBanner(),
          LoadingBannerGrid(),
        ],
      );
    }

    return Column(
      children: [
        SectionBanner(
          gradientColors: snapSection.colors.map((e) => Color(e)).toList(),
          snaps: [bannerSnap, bannerSnap2, bannerSnap3],
          section: snapSection,
        ),
        snapSection == SnapSection.games
            ? GridView(
                shrinkWrap: true,
                padding: kGridPadding,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: kImageGridDelegate,
                children: [
                  for (final app in apps
                          ?.where((a) => a.snap!.bannerUrl != null)
                          .toList() ??
                      <AppFinding>[])
                    AppImageBanner(snap: app.snap!),
                ],
              )
            : SectionGrid(
                apps: apps ?? [],
                take: 20,
                skip: 3,
              ),
      ],
    );
  }
}

class _LoadingSectionBanner extends StatelessWidget {
  // ignore: unused_element
  const _LoadingSectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var light = theme.brightness == Brightness.light;
    final shimmerBase =
        light ? const Color.fromARGB(120, 228, 228, 228) : YaruColors.jet;
    final shimmerHighLight =
        light ? const Color.fromARGB(200, 247, 247, 247) : YaruColors.coolGrey;
    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: SectionBanner(
        snaps: const [],
        section: SnapSection.all,
        gradientColors: SnapSection.all.colors.map((e) => Color(e)).toList(),
      ),
    );
  }
}
