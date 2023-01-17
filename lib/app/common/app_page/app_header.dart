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
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/publisher_name.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
const iconSize = 116.0;

class BannerAppHeader extends StatelessWidget {
  const BannerAppHeader({
    super.key,
    required this.appData,
    required this.controls,
    required this.icon,
    required this.windowSize,
    this.subControls,
  });

  final AppData appData;
  final Widget controls;
  final Widget? subControls;

  final Widget icon;
  final Size windowSize;

  @override
  Widget build(BuildContext context) {
    final scaledFontSize = (800 / appData.title.length.toDouble());
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: iconSize,
              width: iconSize,
              child: icon,
            ),
            const SizedBox(width: kYaruPagePadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appData.title,
                    style: theme.textTheme.headline3!.copyWith(
                      fontSize: scaledFontSize > 44 ? 44 : scaledFontSize,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  controls,
                  if (subControls != null)
                    Padding(
                      padding: const EdgeInsets.only(top: kYaruPagePadding),
                      child: subControls!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PageAppHeader extends StatelessWidget {
  const PageAppHeader({
    super.key,
    required this.appData,
    required this.controls,
    required this.icon,
    this.subControls,
  });

  final AppData appData;
  final Widget controls;
  final Widget icon;
  final Widget? subControls;

  @override
  Widget build(BuildContext context) {
    final scaledFontSize = (800 / appData.title.length.toDouble());
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            SizedBox(
              height: iconSize,
              width: iconSize,
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.all(kYaruPagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    appData.title,
                    style: theme.textTheme.headline3!.copyWith(
                      fontSize: scaledFontSize > 44 ? 44 : scaledFontSize,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: PublisherName(
                      height: 20,
                      publisherName: appData.publisherName ?? '',
                      website: appData.website,
                      verified: appData.verified,
                      starDev: appData.starredDeveloper,
                      limitChildWidth: false,
                      enhanceChildText: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        controls,
        if (subControls != null) subControls!,
        Text(
          appData.summary,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
