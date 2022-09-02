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
import 'package:software/services/app_change_service.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:software/services/color_generator.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapBannerCarousel extends StatefulWidget {
  const SnapBannerCarousel({
    Key? key,
    required this.snapSection,
    this.duration = const Duration(seconds: 3),
    this.height = 178,
  }) : super(key: key);

  final SnapSection snapSection;
  final Duration duration;
  final double height;

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
        ? Padding(
            padding: const EdgeInsets.only(
              top: 20,
              right: 20,
              left: 20,
            ),
            child: YaruCarousel(
              viewportFraction: 1,
              placeIndicator: false,
              autoScrollDuration: widget.duration,
              width: size.width,
              height: widget.height,
              autoScroll: true,
              children: [
                for (final snap in sections)
                  _AppBannerCarouselItem.create(context, snap)
              ],
            ),
          )
        : const SizedBox();
  }
}

class _AppBannerCarouselItem extends StatefulWidget {
  const _AppBannerCarouselItem({
    Key? key,
    required this.snap,
  }) : super(key: key);

  final Snap snap;

  static Widget create(BuildContext context, Snap snap) {
    return ChangeNotifierProvider<SnapModel>(
      create: (_) => SnapModel(
        getService<SnapdClient>(),
        getService<AppChangeService>(),
        huskSnapName: snap.name,
        colorGenerator: getService<ColorGenerator>(),
        doneString: context.l10n.done,
      ),
      child: _AppBannerCarouselItem(snap: snap),
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
      watermark: true,
      name: widget.snap.name,
      summary: widget.snap.summary,
      url: widget.snap.iconUrl,
      surfaceTintColor: model.surfaceTintColor,
      onTap: () => showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
          value: model,
          child: const SnapDialog(),
        ),
      ),
      fallbackIconData: YaruIcons.package_snap,
    );
  }
}
