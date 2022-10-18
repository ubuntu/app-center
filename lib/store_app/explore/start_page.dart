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
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/snap_banner_carousel.dart';
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
    final screenWidth = widget.screenSize.width;

    int amount = 2;

    if (screenWidth > 1000) amount = 4;

    if (screenWidth > 1400) amount = 10;

    final model = context.watch<ExploreModel>();
    if (model.sectionNameToSnapsMap.length < SnapSection.values.length) {
      return const Center(child: YaruCircularProgressIndicator());
    }
    final carouselAmount = screenWidth > 1400
        ? 3
        : screenWidth > 1000
            ? 2
            : 1;
    const spacing = 8.0;

    return SingleChildScrollView(
      primary: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                for (int i = 0;
                    i <
                        SnapSection.values
                            .take(
                              carouselAmount,
                            )
                            .length;
                    i++)
                  Expanded(
                    child: Padding(
                      padding: carouselAmount == 1
                          ? EdgeInsets.zero
                          : EdgeInsets.only(
                              left: i != 0 ? spacing : 0,
                              right:
                                  carouselAmount > 2 && i != carouselAmount - 1
                                      ? spacing
                                      : 0,
                            ),
                      child: SnapBannerCarousel(
                        initialIndex: Random.secure().nextInt(10),
                        duration: const Duration(seconds: 30),
                        snapSection: SnapSection.values
                            .take(
                              carouselAmount,
                            )
                            .elementAt(i),
                        height: 220,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (final section in SnapSection.values)
            if (section != SnapSection.all && section != SnapSection.featured)
              Column(
                children: [
                  _SeciontHeader(
                    section: section,
                    onViewMore: () => model.selectedSection = section,
                  ),
                  _StartPageGrid(
                    snapSection: section,
                    amount: amount,
                  ),
                ],
              )
        ],
      ),
    );
  }
}

class _SeciontHeader extends StatelessWidget {
  const _SeciontHeader({
    Key? key,
    required this.section,
    required this.onViewMore,
  }) : super(key: key);

  final SnapSection section;
  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onViewMore,
            child: Text(
              section.localize(context.l10n),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          TextButton(
            onPressed: onViewMore,
            child: Text(
              context.l10n.showMore,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w200,
                  ),
            ),
          )
        ],
      ),
    );
  }
}

class _StartPageGrid extends StatefulWidget {
  const _StartPageGrid({
    // ignore: unused_element
    super.key,
    required this.snapSection,
    required this.amount,
  });

  final SnapSection snapSection;
  final int amount;

  @override
  State<_StartPageGrid> createState() => __StartPageGridState();
}

class __StartPageGridState extends State<_StartPageGrid> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    final sections =
        model.sectionNameToSnapsMap[widget.snapSection.title] ?? [];
    if (sections.isEmpty) return const SizedBox();
    return GridView.builder(
      padding: const EdgeInsets.only(
        left: 20,
        bottom: 15,
        right: 20,
      ),
      shrinkWrap: true,
      gridDelegate: kGridDelegate,
      itemCount: sections.take(widget.amount).length,
      itemBuilder: (context, index) {
        final snap = sections.take(widget.amount).elementAt(index);

        return YaruBanner(
          title: Text(snap.name),
          subtitle: Text(
            snap.summary,
            overflow: TextOverflow.ellipsis,
          ),
          icon: AppIcon(iconUrl: snap.iconUrl),
          iconPadding: const EdgeInsets.only(left: 10, right: 5),
          onTap: () => model.selectedSnap = snap,
        );
      },
    );
  }
}
