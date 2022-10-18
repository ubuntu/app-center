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
import 'package:yaru_icons/yaru_icons.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.iconUrl,
    this.fallBackIconData = YaruIcons.snapcraft,
    this.size = 45,
    this.fallBackIconSize = 20,
  });

  final String? iconUrl;
  final IconData fallBackIconData;
  final double size;
  final double fallBackIconSize;

  @override
  Widget build(BuildContext context) {
    final fallBackIcon = BorderContainer(
      containerPadding: EdgeInsets.zero,
      borderRadius: 200,
      width: size,
      height: size,
      child: Icon(
        fallBackIconData,
        size: fallBackIconSize,
      ),
    );

    return iconUrl == null || iconUrl!.isEmpty
        ? fallBackIcon
        : SizedBox(
            height: size,
            width: size,
            child: Image.network(
              iconUrl!,
              filterQuality: FilterQuality.medium,
              fit: BoxFit.fitHeight,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                return frame == null ? fallBackIcon : child;
              },
              errorBuilder: (context, error, stackTrace) => fallBackIcon,
            ),
          );
  }
}
