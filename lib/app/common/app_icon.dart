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
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.iconUrl,
    this.size = 45,
    this.borderColor,
    this.color,
  });

  final String? iconUrl;
  final double size;
  final Color? borderColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fallBackIcon = YaruPlaceholderIcon(size: Size.square(size));

    final theme = Theme.of(context);
    var light = theme.brightness == Brightness.light;
    final shimmerBase = color ??
        (light
            ? const Color.fromARGB(120, 228, 228, 228)
            : const Color.fromARGB(255, 51, 51, 51));
    final shimmerHighLight = borderColor ??
        (light
            ? const Color.fromARGB(200, 247, 247, 247)
            : const Color.fromARGB(255, 57, 57, 57));
    final fallBackLoadingIcon = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: fallBackIcon,
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
                return frame == null
                    ? fallBackLoadingIcon
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        child: child,
                      );
              },
              errorBuilder: (context, error, stackTrace) => fallBackIcon,
            ),
          );
  }
}
