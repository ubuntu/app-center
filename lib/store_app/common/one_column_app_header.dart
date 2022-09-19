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
import 'package:software/store_app/common/app_website.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class OneColumnAppHeader extends StatelessWidget {
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

  const OneColumnAppHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.summary,
    required this.version,
    required this.strict,
    required this.confinementName,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.verified,
    required this.publisherName,
    required this.website,
    required this.controls,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final wideEnough = screenWidth > 750;
    final height = wideEnough ? 150.0 : 40.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: icon,
        ),
        SizedBox(width: wideEnough ? 30 : 10),
        Expanded(
          child: SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: wideEnough
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (wideEnough)
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headline3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (wideEnough)
                      AppWebsite(
                        website: website,
                        verified: verified,
                        publisherName: publisherName,
                      ),
                  ],
                ),
                controls,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
