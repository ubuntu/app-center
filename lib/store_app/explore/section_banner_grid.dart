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
import 'package:software/snapx.dart';
import 'package:software/store_app/common/animated_scroll_view_item.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/safe_network_image.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SectionBannerGrid extends StatefulWidget {
  const SectionBannerGrid({
    Key? key,
    required this.snapSection,
    this.animateBanners = false,
    this.padding,
    this.initSection = true,
    required this.initialAmount,
  }) : super(key: key);

  final SnapSection snapSection;
  final bool animateBanners;
  final EdgeInsets? padding;
  final bool initSection;
  final int initialAmount;

  @override
  State<SectionBannerGrid> createState() => _SectionBannerGridState();
}

class _SectionBannerGridState extends State<SectionBannerGrid> {
  late ScrollController _controller;
  late int _amount;
  @override
  void initState() {
    _amount = widget.initialAmount;
    _controller = ScrollController();

    if (widget.initSection) {
      context.read<ExploreModel>().loadSection(widget.snapSection);
      _controller.addListener(() {
        if (_controller.position.maxScrollExtent == _controller.offset) {
          setState(() {
            _amount = _amount + 5;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    final sections =
        model.sectionNameToSnapsMap[widget.snapSection.title] ?? [];
    if (sections.isEmpty) return const SizedBox();

    return GridView.builder(
      controller: _controller,
      padding: widget.padding ?? const EdgeInsets.all(20),
      shrinkWrap: true,
      gridDelegate: kGridDelegate,
      itemCount: sections.take(_amount).length,
      itemBuilder: (context, index) {
        final snap = sections.take(_amount).elementAt(index);

        final banner = YaruBanner(
          title: Text(snap.name),
          subtitle: Text(
            snap.summary,
            overflow: TextOverflow.ellipsis,
          ),
          icon: Padding(
            padding:
                const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 5),
            child: SizedBox(
              height: 50,
              child: SafeNetworkImage(
                url: snap.iconUrl,
                fallBackIconData: YaruIcons.snapcraft,
              ),
            ),
          ),
          onTap: () => model.selectedSnap = snap,
        );

        if (widget.animateBanners) {
          return AnimatedScrollViewItem(
            child: banner,
          );
        } else {
          return banner;
        }
      },
    );
  }
}
