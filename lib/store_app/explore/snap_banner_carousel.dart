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
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/color_generator.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_website.dart';
import 'package:software/store_app/common/safe_network_image.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapBannerCarousel extends StatefulWidget {
  const SnapBannerCarousel({
    Key? key,
    required this.snapSection,
    this.duration = const Duration(seconds: 3),
    this.height = 178,
    this.initialIndex = 0,
  }) : super(key: key);

  final SnapSection snapSection;
  final Duration duration;
  final double height;
  final int initialIndex;

  @override
  State<SnapBannerCarousel> createState() => _SnapBannerCarouselState();
}

class _SnapBannerCarouselState extends State<SnapBannerCarousel> {
  @override
  void initState() {
    super.initState();
    context.read<ExploreModel>().loadSection(widget.snapSection);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    final size = MediaQuery.of(context).size;
    final sections =
        model.sectionNameToSnapsMap[widget.snapSection.title] ?? [];
    return sections.isNotEmpty
        ? YaruCarousel(
            controller: YaruCarouselController(
              pagesLength: sections.length,
              initialPage: widget.initialIndex,
              viewportFraction: 1,
              autoScrollDuration: widget.duration,
              autoScroll: true,
            ),
            placeIndicator: false,
            width: size.width,
            height: widget.height,
            children: [
              for (final snap in sections)
                _AppBannerCarouselItem.create(
                  context: context,
                  snap: snap,
                  sectionName: widget.snapSection == SnapSection.all
                      ? SnapSection.featured.localize(context.l10n)
                      : widget.snapSection.localize(context.l10n),
                  onTap: () => model.selectedSnap = snap,
                )
            ],
          )
        : const SizedBox();
  }
}

class _AppBannerCarouselItem extends StatefulWidget {
  const _AppBannerCarouselItem({
    Key? key,
    required this.snap,
    required this.sectionName,
    required this.onTap,
  }) : super(key: key);

  final Snap snap;
  final String sectionName;
  final VoidCallback onTap;

  static Widget create({
    required BuildContext context,
    required Snap snap,
    required VoidCallback onTap,
    required String sectionName,
  }) {
    return ChangeNotifierProvider<SnapModel>(
      create: (_) => SnapModel(
        getService<SnapService>(),
        huskSnapName: snap.name,
        colorGenerator: getService<ColorGenerator>(),
        doneMessage: context.l10n.done,
      ),
      child: _AppBannerCarouselItem(
        snap: snap,
        onTap: onTap,
        sectionName: sectionName,
      ),
    );
  }

  @override
  State<_AppBannerCarouselItem> createState() => _AppBannerCarouselItemState();
}

class _AppBannerCarouselItemState extends State<_AppBannerCarouselItem> {
  @override
  void initState() {
    super.initState();
    context.read<SnapModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    return YaruBanner(
      copyIconAsWatermark: true,
      title: Text(
        widget.snap.name,
        style: Theme.of(context).textTheme.headline4,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(widget.sectionName),
      surfaceTintColor: model.surfaceTintColor,
      thirdTitle: AppWebsite(
        tapAble: false,
        height: 14,
        website:
            widget.snap.website ?? widget.snap.publisher?.displayName ?? '',
        verified: widget.snap.publisher?.validation == 'verified',
        publisherName: widget.snap.publisher?.displayName ?? widget.snap.name,
      ),
      onTap: widget.onTap,
      icon: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 5),
        child: SizedBox(
          height: 85,
          child: SafeNetworkImage(
            url: widget.snap.iconUrl,
            fallBackIconData: YaruIcons.package_snap,
          ),
        ),
      ),
      watermarkIcon: SizedBox(
        height: 130,
        child: SafeNetworkImage(
          url: widget.snap.iconUrl,
          fallBackIconData: YaruIcons.package_snap,
        ),
      ),
    );
  }
}
