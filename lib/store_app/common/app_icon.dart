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

import 'package:flutter/widgets.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/safe_network_image.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.iconUrl,
    required this.fallBackIconData,
    required this.size,
    this.iconSize = 80,
  });

  final String? iconUrl;
  final IconData fallBackIconData;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return iconUrl == null || iconUrl!.isEmpty
        ? BorderContainer(
            containerPadding: EdgeInsets.zero,
            borderRadius: 200,
            width: size,
            height: size,
            child: Icon(
              fallBackIconData,
              size: iconSize,
            ),
          )
        : SizedBox(
            height: size,
            width: size,
            child: SafeNetworkImage(
              url: iconUrl,
              fallBackIconData: fallBackIconData,
              iconSize: iconSize,
            ),
          );
  }
}
