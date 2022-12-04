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
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/preview_banner.dart';
import 'package:software/store_app/common/snap/snap_control_button.dart';
import 'package:software/store_app/common/snap/snap_page.dart';
import 'package:software/store_app/common/snap/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';

class SectionGrid extends StatelessWidget {
  const SectionGrid({
    Key? key,
    required this.snapSection,
    this.animateBanners = false,
    this.padding,
    this.initSection = true,
    this.ignoreScrolling = true,
    required this.initialAmount,
  }) : super(key: key);

  final SnapSection snapSection;
  final bool animateBanners;
  final EdgeInsets? padding;
  final bool initSection;
  final int initialAmount;
  final bool ignoreScrolling;

  @override
  Widget build(BuildContext context) {
    final sections = context.select((ExploreModel m) {
      return m.sectionNameToSnapsMap[snapSection]?.take(initialAmount).toList();
    });
    if (sections == null || sections.isEmpty) return const SizedBox();

    return GridView.builder(
      physics: ignoreScrolling ? const NeverScrollableScrollPhysics() : null,
      padding:
          padding ?? const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      shrinkWrap: true,
      gridDelegate: kGridDelegate,
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final snap = sections.elementAt(index);

        return PreviewBanner(
          controlWidget: SnapControlButton.create(
            context: context,
            huskSnapName: snap.name,
          ),
          title: snap.name,
          subTitle: snap.summary,
          description:
              '${snap.publisher?.displayName ?? ''} | ${context.l10n.version}: ${snap.version}',
          icon: Padding(
            padding: kIconPadding,
            child: AppIcon(
              iconUrl: snap.iconUrl,
            ),
          ),
          onTap: () => SnapPage.push(context, snap),
        );
      },
    );
  }
}
