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
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MediaTile extends StatelessWidget {
  const MediaTile({
    Key? key,
    required this.url,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        excludeFromSemantics: true,
        onTap: () => showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: YaruSafeImage(
                  url: url,
                  fit: fit,
                  filterQuality: FilterQuality.medium,
                  fallBackIconData: YaruIcons.image,
                ),
              )
            ],
          ),
        ),
        child: YaruSafeImage(
          url: url,
          fallBackIconData: YaruIcons.image,
        ),
      ),
    );
  }
}
