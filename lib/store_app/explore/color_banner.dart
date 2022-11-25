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
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../l10n/l10n.dart';
import '../../services/color_generator.dart';
import '../../services/snap_service.dart';
import '../../snapx.dart';
import '../common/app_icon.dart';
import '../common/app_website.dart';
import '../common/snap/snap_model.dart';

class ColorBanner extends StatefulWidget {
  const ColorBanner({
    super.key,
    required this.snap,
    required this.sectionName,
    required this.onTap,
  });

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
      child: ColorBanner(
        snap: snap,
        onTap: onTap,
        sectionName: sectionName,
      ),
    );
  }

  @override
  State<ColorBanner> createState() => _ColorBannerState();
}

class _ColorBannerState extends State<ColorBanner> {
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
        style: Theme.of(context)
            .textTheme
            .headline4!
            .copyWith(fontWeight: FontWeight.w300),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(widget.sectionName),
      surfaceTintColor: model.surfaceTintColor,
      thirdTitle: AppWebsite(
        height: 14,
        website:
            widget.snap.website ?? widget.snap.publisher?.displayName ?? '',
        verified: model.verified,
        starredDeveloper: model.starredDeveloper,
        publisherName: widget.snap.publisher?.displayName ?? widget.snap.name,
      ),
      onTap: widget.onTap,
      iconPadding: const EdgeInsets.only(left: 20, right: 10),
      icon: AppIcon(
        iconUrl: widget.snap.iconUrl,
        size: 80,
      ),
      watermarkIcon: AppIcon(
        iconUrl: widget.snap.iconUrl,
        size: 130,
      ),
    );
  }
}
