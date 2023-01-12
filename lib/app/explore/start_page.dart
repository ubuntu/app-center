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
import 'package:snapd/snapd.dart';
import 'package:software/app/common/custom_back_button.dart';
import 'package:software/app/common/loading_banner_grid.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:software/app/explore/section_banner.dart';
import 'package:software/app/explore/section_grid.dart';
import 'package:software/snapx.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
  });

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
    final searchQuery = context.select((ExploreModel m) => m.searchQuery);
    final setSearchQuery = context.read<ExploreModel>().setSearchQuery;
    final sectionSnapsAll = context.select((ExploreModel m) {
      return m.sectionNameToSnapsMap[SnapSection.all];
    });

    final page = SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: [
          _TeaserPage(
            snapSection: SnapSection.all,
            snaps: sectionSnapsAll,
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: YaruWindowTitleBar(
        leading: MediaQuery.of(context).size.width < 611
            ? const CustomBackButton()
            : null,
        titleSpacing: 0,
        centerTitle: false,
        title: SearchField(
          searchQuery: searchQuery,
          onChanged: setSearchQuery,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: page,
      ),
    );
  }
}

class _TeaserPage extends StatelessWidget {
  const _TeaserPage({
    required this.snapSection,
    this.snaps,
  });

  final SnapSection snapSection;
  final List<Snap>? snaps;

  @override
  Widget build(BuildContext context) {
    final snapsWithIcons =
        snaps?.where((snap) => snap.iconUrl != null).toList();
    Snap? bannerSnap;
    Snap? bannerSnap2;
    Snap? bannerSnap3;

    if (snapsWithIcons != null && snapsWithIcons.isNotEmpty) {
      bannerSnap = snapsWithIcons.elementAt(0);
      bannerSnap2 = snapsWithIcons.elementAt(1);
      bannerSnap3 = snapsWithIcons.elementAt(2);
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
        SectionGrid(
          snaps: snaps ?? [],
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
