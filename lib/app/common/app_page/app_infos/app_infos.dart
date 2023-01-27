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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/app/common/app_page/app_infos/app_size_fragment.dart';
import 'package:software/app/common/app_page/app_infos/confinment_info_fragment.dart';
import 'package:software/app/common/app_page/app_infos/version_info_fragment.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class AppInfos extends StatelessWidget {
  const AppInfos({
    super.key,
    required this.appData,
    this.alignment = Alignment.center,
    this.wrapAlignment = WrapAlignment.center,
    this.runAlignment = WrapAlignment.center,
    this.direction = Axis.horizontal,
  });

  final AppData appData;

  final Axis direction;
  final AlignmentGeometry alignment;
  final WrapAlignment wrapAlignment;
  final WrapAlignment runAlignment;

  @override
  Widget build(BuildContext context) {
    final appInfos = [
      RatingInfoFragment(averageRating: appData.averageRating ?? 0),
      ConfinementInfoFragment(
        strict: appData.strict,
        confinementName: appData.confinementName,
      ),
      VersionInfoFragment(
        version: appData.version,
        versionChanged: appData.versionChanged,
      ),
      AppSizeFragment(appSize: appData.appSize),
    ];

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (final info in appInfos) Expanded(child: info)],
      ),
    );
  }
}

class RatingInfoFragment extends StatelessWidget {
  const RatingInfoFragment({
    super.key,
    required this.averageRating,
  });

  final double averageRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bar = RatingBar.builder(
      initialRating: averageRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.zero,
      itemSize: 15,
      itemBuilder: (context, _) => const Icon(
        YaruIcons.star_filled,
        color: kStarColor,
        size: 2,
      ),
      unratedColor: theme.colorScheme.onSurface.withOpacity(0.2),
      onRatingUpdate: (rating) {},
      ignoreGestures: true,
    );

    return AppInfoFragment(
      header: context.l10n.rating,
      tooltipMessage: averageRating.toString(),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: bar,
        ),
      ),
    );
  }
}
