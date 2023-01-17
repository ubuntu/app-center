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
import 'package:shimmer/shimmer.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const _borderColor = Color.fromARGB(255, 189, 189, 189);

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
    final fallBackIcon = YaruBorderContainer(
      border: Border.all(color: _borderColor),
      borderRadius: BorderRadius.circular(200),
      width: size,
      height: size,
      child: _FallBackIcon(
        size: size,
      ),
    );

    final shimmerBase = color ?? (const Color.fromARGB(120, 228, 228, 228));
    final shimmerHighLight =
        borderColor ?? (const Color.fromARGB(200, 247, 247, 247));
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

class _FallBackIcon extends StatelessWidget {
  const _FallBackIcon({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    const border = BorderSide(
      color: _borderColor,
      width: 0.5,
    );
    const shadeMax = Color.fromARGB(255, 199, 199, 199);
    const shadeMid = Color.fromARGB(255, 214, 214, 214);
    const shadeMin = Color.fromARGB(255, 236, 236, 236);
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
                    decoration: const BoxDecoration(
                      border: Border(
                        right: border,
                      ),
                      color: shadeMid,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(size),
                    decoration: const BoxDecoration(
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
                    decoration: const BoxDecoration(
                      color: shadeMin,
                      border: Border(
                        bottom: border,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(size * 1.2),
                    decoration: const BoxDecoration(color: shadeMid),
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
