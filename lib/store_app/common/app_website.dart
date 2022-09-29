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
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppWebsite extends StatelessWidget {
  const AppWebsite({
    Key? key,
    required this.website,
    required this.verified,
    required this.publisherName,
  }) : super(key: key);

  final String website;
  final bool verified;
  final String publisherName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => launchUrl(Uri.parse(website)),
      child: Tooltip(
        message: website,
        child: SizedBox(
          height: 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (verified)
                const Icon(
                  Icons.verified,
                  size: 20,
                  color: YaruColors.success,
                ),
              if (website.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    left: verified ? 5 : 0,
                    right: 5,
                  ),
                  child: Text(
                    publisherName,
                    style: const TextStyle(
                      fontSize: 15,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              if (website.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(right: verified ? 5 : 0),
                  child: Icon(
                    YaruIcons.external_link,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
