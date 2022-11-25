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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../snapx.dart';
import 'explore_model.dart';
import 'section_banner.dart';
import 'section_grid.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    super.key,
    required this.screenSize,
  });

  final Size screenSize;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late int _randomSnapIndex;
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

    _randomSnapIndex = Random().nextInt(10);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    final bannerSection = model.selectedSection;

    final snapsWithIcons = model.sectionNameToSnapsMap[model.selectedSection]
        ?.where((snap) => snap.iconUrl != null);

    final bannerSnap = snapsWithIcons?.elementAt(_randomSnapIndex);
    final bannerSnap2 = snapsWithIcons?.elementAt(_randomSnapIndex + 1);
    final bannerSnap3 = snapsWithIcons?.elementAt(_randomSnapIndex + 2);

    if (bannerSnap == null || bannerSnap2 == null || bannerSnap3 == null) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: [
          SectionBanner(
            gradientColors: bannerSection.colors.map(Color.new).toList(),
            snaps: [bannerSnap, bannerSnap2, bannerSnap3],
            section: bannerSection,
          ),
          SectionGrid(
            snapSection: model.selectedSection,
            initialAmount: _amount,
          ),
        ],
      ),
    );
  }
}
