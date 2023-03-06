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
import 'package:shimmer/shimmer.dart';
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/app_rating.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/loading_banner_grid.dart';
import 'package:software/app/common/rating_model.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/explore/section_banner.dart';
import 'package:software/app/explore/section_grid.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    this.apps,
    required this.snapSection,
    this.topRatedApps,
    this.gameApps,
  });

  final List<AppFinding>? apps;
  final List<AppFinding>? topRatedApps;
  final List<AppFinding>? gameApps;

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

    _amount = 20;
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
          _Page(
            snapSection: widget.snapSection,
            apps: widget.apps,
            amount: _amount,
            topRatedApps: widget.topRatedApps,
            gameApps: widget.gameApps,
          ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.snapSection,
    this.apps,
    this.amount = 10,
    this.topRatedApps,
    this.gameApps,
  });

  final SnapSection snapSection;
  final List<AppFinding>? apps;
  final int amount;
  final List<AppFinding>? topRatedApps;
  final List<AppFinding>? gameApps;

  @override
  Widget build(BuildContext context) {
    final getRating = context.read<RatingModel>().getRating;

    var tops = <AppFinding, double>{};

    for (var app in topRatedApps ?? <AppFinding>[]) {
      if (app.snap != null) {
        final rating = getRating(app.snap!.ratingId);
        if (rating != null && rating.total! > 500) {
          tops.putIfAbsent(app, () => rating.average!);
        }
      }
    }

    tops = Map.fromEntries(
      tops.entries.toList()
        ..sort((e1, e2) {
          return e2.value.compareTo(e1.value);
        }),
    );

    var showTopApps =
        snapSection == SnapSection.all && topRatedApps?.isNotEmpty == true;

    final appsWithIcons =
        apps?.where((app) => app.snap?.iconUrl != null).toList();
    AppFinding? bannerApp;
    AppFinding? bannerApp2;
    AppFinding? bannerApp3;

    if (appsWithIcons != null && appsWithIcons.isNotEmpty) {
      bannerApp = appsWithIcons.elementAt(0);
      bannerApp2 = appsWithIcons.elementAt(1);
      bannerApp3 = appsWithIcons.elementAt(2);
    }
    if (bannerApp == null || bannerApp2 == null || bannerApp3 == null) {
      return Column(
        children: const [
          _LoadingSectionBanner(),
          LoadingBannerGrid(),
        ],
      );
    }

    final allChildren = [
      SectionBanner(
        gradientColors: snapSection.colors.map((e) => Color(e)).toList(),
        apps: [bannerApp, bannerApp2, bannerApp3],
        section: snapSection,
      ),
      if (showTopApps)
        Padding(
          padding: const EdgeInsets.only(
            left: kYaruPagePadding,
            right: kYaruPagePadding,
            bottom: kYaruPagePadding,
          ),
          child: Row(
            children: [
              Text(
                context.l10n.topRatedSnaps,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w100),
              ),
            ],
          ),
        ),
      if (showTopApps)
        SectionGrid(apps: tops.entries.take(6).map((e) => e.key).toList()),
      if (gameApps?.isNotEmpty == true)
        Padding(
          padding: const EdgeInsets.all(kYaruPagePadding),
          child: Row(
            children: [
              Text(
                SnapSection.games.slogan(context.l10n),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w100),
              ),
            ],
          ),
        ),
      if (gameApps?.isNotEmpty == true)
        GridView(
          shrinkWrap: true,
          padding: kGridPadding,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: kImageGridDelegate,
          children: [
            for (final app in gameApps
                    ?.where((a) => a.snap!.bannerUrl != null)
                    .toList()
                    .take(6) ??
                <AppFinding>[])
              AppImageBanner(snap: app.snap!),
          ],
        ),
    ];
    return Column(
      children: snapSection == SnapSection.all
          ? allChildren
          : [
              SectionBanner(
                gradientColors:
                    snapSection.colors.map((e) => Color(e)).toList(),
                apps: [bannerApp, bannerApp2, bannerApp3],
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
                                .toList()
                                .take(6) ??
                            <AppFinding>[])
                          AppImageBanner(snap: app.snap!),
                      ],
                    )
                  : SectionGrid(
                      apps: apps ?? [],
                      take: amount,
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
        apps: const [],
        section: SnapSection.all,
        gradientColors: SnapSection.all.colors.map((e) => Color(e)).toList(),
      ),
    );
  }
}
