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
import 'package:software/store_app/common/app_infos.dart';
import 'package:software/store_app/common/app_website.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class BannerAppHeader extends StatelessWidget {
  const BannerAppHeader({
    super.key,
    required this.headerData,
  });

  final AppHeaderData headerData;

  @override
  Widget build(BuildContext context) {
    const height = 150.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: headerData.icon,
        ),
        const SizedBox(width: 30),
        Expanded(
          child: SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerData.title,
                      style: Theme.of(context).textTheme.headline3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppWebsite(
                      website: headerData.website,
                      verified: headerData.verified,
                      publisherName: headerData.publisherName,
                    ),
                  ],
                ),
                headerData.controls,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PageAppHeader extends StatelessWidget {
  const PageAppHeader({
    super.key,
    required this.headerData,
  });

  final AppHeaderData headerData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            SizedBox(
              height: 180,
              child: headerData.icon,
            ),
            Text(
              headerData.title,
              style: Theme.of(context).textTheme.headline3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            AppWebsite(
              website: headerData.website,
              verified: headerData.verified,
              publisherName: headerData.publisherName,
            ),
          ],
        ),
        headerData.controls,
        AppInfos(
          strict: headerData.strict,
          confinementName: headerData.confinementName,
          license: headerData.license,
          installDate: headerData.installDate,
          installDateIsoNorm: headerData.installDateIsoNorm,
          version: headerData.version,
        ),
        Text(
          headerData.summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class AppHeaderData {
  final Widget? icon;
  final String title;
  final String summary;
  final bool strict;
  final String confinementName;
  final String version;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final bool verified;
  final String publisherName;
  final String website;
  final Widget controls;

  AppHeaderData({
    this.icon,
    required this.title,
    required this.summary,
    required this.strict,
    required this.confinementName,
    required this.version,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.verified,
    required this.publisherName,
    required this.website,
    required this.controls,
  });
}
