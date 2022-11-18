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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:software/store_app/common/border_container.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.iconUrl,
    this.size = 45,
  });

  final String? iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallBackIcon = BorderContainer(
      clipBehavior: Clip.hardEdge,
      containerPadding: EdgeInsets.zero,
      borderRadius: 200,
      width: size,
      height: size,
      child: _FallBackIcon(size: size),
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

class _FallBackIcon extends StatelessWidget {
  const _FallBackIcon({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final border = BorderSide(
      color: light ? Colors.white : theme.dividerColor,
      width: light ? 0.5 : 0.3,
    );
    final shadeMax = light
        ? theme.dividerColor.withOpacity(0.1)
        : theme.colorScheme.onSurface.withOpacity(0.03);
    final shadeMid = light
        ? theme.dividerColor.withOpacity(0.05)
        : theme.colorScheme.onSurface.withOpacity(0.015);
    final shadeMin = light
        ? theme.dividerColor.withOpacity(0.005)
        : theme.colorScheme.onSurface.withOpacity(0.005);
    return ClipOval(
      child: FittedBox(
        fit: BoxFit.none,
        child: Transform.rotate(
          angle: -pi / 4,
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(size),
                    decoration: BoxDecoration(
                      border: Border(
                        right: border,
                      ),
                      color: shadeMid,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(size),
                    decoration: BoxDecoration(
                      color: shadeMax,
                      border: Border(
                        top: border,
                        right: border,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(size * 1.2),
                    decoration: BoxDecoration(
                      color: shadeMin,
                      border: Border(
                        bottom: border,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(size * 1.2),
                    decoration: BoxDecoration(color: shadeMid),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
