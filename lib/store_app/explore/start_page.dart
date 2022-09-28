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
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/section_banner_grid.dart';
import 'package:software/store_app/explore/snap_banner_carousel.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StartPage extends StatefulWidget {
  const StartPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    final model = context.read<ExploreModel>();

    for (var section in SnapSection.values) {
      model.loadSection(section);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int amount = 2;

    if (screenWidth > 1000) amount = 4;

    if (screenWidth > 1400) amount = 10;

    final model = context.watch<ExploreModel>();
    if (model.sectionNameToSnapsMap.length < SnapSection.values.length) {
      return const Center(child: YaruCircularProgressIndicator());
    }
    return SingleChildScrollView(
      primary: true,
      child: Column(
        children: [
          screenWidth > 1400
              ? Row(
                  children: const [
                    Expanded(
                      child: SnapBannerCarousel(
                        duration: Duration(seconds: 10),
                        snapSection: SnapSection.featured,
                        height: 220,
                      ),
                    ),
                    Expanded(
                      child: SnapBannerCarousel(
                        duration: Duration(seconds: 8),
                        snapSection: SnapSection.development,
                        height: 220,
                      ),
                    ),
                    Expanded(
                      child: SnapBannerCarousel(
                        duration: Duration(seconds: 12),
                        snapSection: SnapSection.games,
                        height: 220,
                      ),
                    ),
                  ],
                )
              : screenWidth > 1000
                  ? Row(
                      children: const [
                        Expanded(
                          child: SnapBannerCarousel(
                            duration: Duration(seconds: 10),
                            snapSection: SnapSection.featured,
                            height: 220,
                          ),
                        ),
                        Expanded(
                          child: SnapBannerCarousel(
                            duration: Duration(seconds: 8),
                            snapSection: SnapSection.development,
                            height: 220,
                          ),
                        ),
                      ],
                    )
                  : const SnapBannerCarousel(
                      duration: Duration(seconds: 15),
                      snapSection: SnapSection.featured,
                      height: 220,
                    ),
          const SizedBox(
            height: 20,
          ),
          for (final section in SnapSection.values)
            if (section != SnapSection.all && section != SnapSection.featured)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          section.localize(context.l10n),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () => model.selectedSection = section,
                          child: Text(
                            context.l10n.showMore,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.w200,
                                    ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SectionBannerGrid(
                    snapSection: section,
                    initSection: false,
                    controller: ScrollController(),
                    amount: amount,
                    animateBanners: false,
                    padding: const EdgeInsets.only(
                      left: 20,
                      bottom: 20,
                      right: 20,
                      top: 5,
                    ),
                  ),
                ],
              )
        ],
      ),
    );
  }
}
