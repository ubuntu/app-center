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
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/snap/snap_page.dart';
import 'package:software/store_app/common/snap/snap_section.dart';
import 'package:software/store_app/explore/color_banner.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/section_grid.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
  late int _randomSnapIndex;

  late ScrollController _controller;
  late int _amount;
  @override
  void initState() {
    super.initState();

    final screenArea = widget.screenSize.width * widget.screenSize.height;
    final bannerArea =
        (kGridDelegate.mainAxisExtent! + kGridDelegate.mainAxisSpacing) *
            (kGridDelegate.crossAxisSpacing + kGridDelegate.maxCrossAxisExtent);
    final initialAmount = ((screenArea - 240) ~/ bannerArea) + 5;

    _amount = initialAmount;
    _controller = ScrollController();

    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        setState(() {
          _amount = _amount + 5;
        });
      }
    });

    super.initState();
    _randomSnapIndex = Random().nextInt(10);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    final bannerSection = model.selectedSection;

    final bannerSnap = model.sectionNameToSnapsMap[model.selectedSection]
        ?.elementAt(_randomSnapIndex);

    if (bannerSnap == null) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: [
          Container(
            height: 200,
            padding: const EdgeInsets.only(
              left: kYaruPagePadding,
              right: kYaruPagePadding,
              bottom: kYaruPagePadding,
            ),
            child: ColorBanner.create(
              context: context,
              snap: bannerSnap,
              sectionName: bannerSection == SnapSection.all
                  ? SnapSection.featured.localize(context.l10n)
                  : bannerSection.localize(context.l10n),
              onTap: () => SnapPage.push(context, bannerSnap),
            ),
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
