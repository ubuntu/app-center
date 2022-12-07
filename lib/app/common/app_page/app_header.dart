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
import 'package:software/app/common/app_page/app_infos.dart';
import 'package:software/app/common/app_website.dart';
import 'package:software/app/common/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
const iconSize = 150.0;

class BannerAppHeader extends StatelessWidget {
  const BannerAppHeader({
    super.key,
    required this.appData,
    required this.controls,
    required this.icon,
  });

  final AppData appData;
  final Widget controls;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final scaledFontSize = (800 / appData.title.length.toDouble());
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: iconSize,
              child: icon,
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appData.title,
                    style: Theme.of(context).textTheme.headline3!.copyWith(
                          fontSize: scaledFontSize > 44 ? 44 : scaledFontSize,
                        ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppWebsite(
                        height: 15,
                        website: appData.website,
                        verified: appData.verified,
                        starredDeveloper: appData.starredDeveloper,
                        publisherName: appData.publisherName,
                        onTap: () => launchUrl(Uri.parse(appData.website)),
                      ),
                      if (appData.publisherName != null ||
                          appData.website.isNotEmpty)
                        const SizedBox(
                          height: 15,
                          child: VerticalDivider(
                            width: 20,
                          ),
                        ),
                      RatingBar.builder(
                        initialRating: appData.averageRating ?? 5,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.zero,
                        itemSize: 15,
                        itemBuilder: (context, _) => const Icon(
                          YaruIcons.star_filled,
                          color: kRatingOrange,
                          size: 2,
                        ),
                        onRatingUpdate: (rating) {},
                        ignoreGestures: true,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: kYaruPagePadding,
                  ),
                  controls,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            SizedBox(
              height: iconSize,
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.all(kYaruPagePadding),
              child: Text(
                appData.title,
                style: Theme.of(context).textTheme.headline3!.copyWith(
                      fontSize: scaledFontSize > 44 ? 44 : scaledFontSize,
                    ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            AppWebsite(
              website: appData.website,
              verified: appData.verified,
              starredDeveloper: appData.starredDeveloper,
              publisherName: appData.publisherName,
              onTap: () => launchUrl(Uri.parse(appData.website)),
            ),
            RatingBar.builder(
              initialRating: appData.averageRating ?? 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.zero,
              itemSize: 15,
              itemBuilder: (context, _) => const Icon(
                YaruIcons.star_filled,
                color: kRatingOrange,
                size: 2,
              ),
              onRatingUpdate: (rating) {},
              ignoreGestures: true,
            )
          ],
        ),
        controls,
        if (subControls != null) subControls!,
        AppInfos(
          strict: appData.strict,
          confinementName: appData.confinementName,
          license: appData.license,
          installDate: appData.installDate,
          installDateIsoNorm: appData.installDateIsoNorm,
          version: appData.version,
          versionChanged: appData.versionChanged,
        ),
        Text(
          appData.summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
