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
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppWebsite extends StatelessWidget {
  const AppWebsite({
    Key? key,
    required this.website,
    required this.verified,
    required this.publisherName,
    this.height = 15.0,
    this.onTap,
  }) : super(key: key);

  final String website;
  final bool verified;
  final String publisherName;
  final double height;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    var sizedBox = SizedBox(
      height: height * 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (verified)
            Icon(
              Icons.verified,
              size: height,
              color: YaruColors.success,
            ),
          if (website.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: verified ? height / 3 : 0,
                right: height / 3,
              ),
              child: Text(
                publisherName,
                style: TextStyle(
                  fontSize: height,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          if (website.isNotEmpty && onTap != null)
            Padding(
              padding: EdgeInsets.only(right: verified ? height / 3 : 0),
              child: Icon(
                YaruIcons.external_link,
                color: Theme.of(context).colorScheme.onSurface,
                size: height,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return sizedBox;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Tooltip(
        message: website,
        child: sizedBox,
      ),
    );
  }
}
