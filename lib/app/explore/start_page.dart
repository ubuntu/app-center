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
import 'package:software/app/explore/explore_model.dart';
import 'package:software/app/explore/section_banner.dart';
import 'package:software/app/explore/section_grid.dart';
import 'package:software/snapx.dart';

class GenericStartPage extends StatefulWidget {
  const GenericStartPage({
    super.key,
    required this.snapSection,
    this.apps,
    required this.appstreamReady,
  });

  final SnapSection snapSection;
  final List<AppFinding>? apps;
  final bool appstreamReady;

  @override
  State<GenericStartPage> createState() => _GenericStartPageState();
}

class _GenericStartPageState extends State<GenericStartPage> {
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
    final appsWithIcons =
        widget.apps?.where((app) => app.snap?.iconUrl != null).toList();
    AppFinding? bannerApp;
    AppFinding? bannerApp2;
    AppFinding? bannerApp3;

    bannerApp = appsWithIcons?.elementAt(0);
    bannerApp2 = appsWithIcons?.elementAt(1);
    bannerApp3 = appsWithIcons?.elementAt(2);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 15),
      controller: _controller,
      child: Column(
        children: [
          SectionBanner(
            gradientColors:
                widget.snapSection.colors.map((e) => Color(e)).toList(),
            apps: [bannerApp, bannerApp2, bannerApp3],
            section: widget.snapSection,
          ),
          SectionGrid(
            apps: widget.apps,
            take: 20,
            skip: 3,
            appstreamReady: true,
          ),
        ],
      ),
    );
  }
}

class ExploreAllPage extends StatefulWidget {
  const ExploreAllPage({super.key, required this.appstreamReady});

  final bool appstreamReady;

  @override
  State<ExploreAllPage> createState() => _ExploreAllPageState();
}

class _ExploreAllPageState extends State<ExploreAllPage> {
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
    final apps = context.read<ExploreModel>().startPageApps[SnapSection.all];
    context.select((ExploreModel m) => m.startPageAppsChanged);

    final appsWithIcons =
        apps?.where((app) => app.snap?.iconUrl != null).toList();
    AppFinding? bannerApp;
    AppFinding? bannerApp2;
    AppFinding? bannerApp3;

    bannerApp = appsWithIcons?.elementAt(0);
    bannerApp2 = appsWithIcons?.elementAt(1);
    bannerApp3 = appsWithIcons?.elementAt(2);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 15),
      controller: _controller,
      child: Column(
        children: [
          SectionBanner(
            gradientColors:
                SnapSection.all.colors.map((e) => Color(e)).toList(),
            apps: [bannerApp, bannerApp2, bannerApp3],
            section: SnapSection.all,
          ),
          SectionGrid(
            apps: apps,
            take: 20,
            skip: 3,
            appstreamReady: widget.appstreamReady,
          ),
        ],
      ),
    );
  }
}

class GamesStartPage extends StatefulWidget {
  const GamesStartPage({super.key});

  @override
  State<GamesStartPage> createState() => _GamesStartPageState();
}

class _GamesStartPageState extends State<GamesStartPage> {
  late ScrollController _controller;
  late int _amount;

  @override
  void initState() {
    super.initState();

    _amount = 30;
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
    final apps = context.read<ExploreModel>().startPageApps[SnapSection.games];

    final appsWithIcons =
        apps?.where((app) => app.snap?.iconUrl != null).toList();
    AppFinding? bannerApp;
    AppFinding? bannerApp2;
    AppFinding? bannerApp3;

    bannerApp = appsWithIcons?.elementAt(0);
    bannerApp2 = appsWithIcons?.elementAt(1);
    bannerApp3 = appsWithIcons?.elementAt(2);

    return SingleChildScrollView(
      controller: _controller,
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          SectionBanner(
            gradientColors:
                SnapSection.games.colors.map((e) => Color(e)).toList(),
            apps: [bannerApp, bannerApp2, bannerApp3],
            section: SnapSection.games,
          ),
          GridView(
            shrinkWrap: true,
            padding: kGridPadding,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: kImageGridDelegate,
            children: [
              for (final app in apps
                      ?.where((a) => a.snap!.bannerUrl != null)
                      .toList()
                      .skip(3) ??
                  <AppFinding>[])
                AppImageBanner(snap: app.snap!),
            ],
          ),
        ],
      ),
    );
  }
}
