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
import 'package:software/app/common/constants.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

/// A [YaruBorderContainer] with software specific defaults.
class BorderContainer extends StatelessWidget {
  const BorderContainer({
    super.key,
    this.height,
    this.width,
    this.child,
    this.borderRadius = 10,
    this.alignment,
    this.color,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.padding = const EdgeInsets.all(kYaruPagePadding),
    this.borderColor,
  });

  /// Forwarded to [Container]
  final double? height;

  /// Forwarded to [Container]
  final double? width;

  /// Forwarded to [Container]
  final EdgeInsets? padding;

  /// Forwarded to [Container]
  final Widget? child;

  /// The radius added to the BoxDecoration of the [Container],
  /// default value is 10 on all edges.
  final double borderRadius;

  /// Forwarded to [Container]
  final AlignmentGeometry? alignment;

  /// Forwarded to [Container]
  final Color? color;

  /// Forwarded to [Container]
  final BoxConstraints? constraints;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry? margin;

  /// The transformation matrix to apply before painting the container.
  final Matrix4? transform;

  /// Forwarded to [Container]
  final AlignmentGeometry? transformAlignment;

  /// Forwarded to [Container]
  final Clip clipBehavior;

  /// Optional color for the border
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final container = YaruBorderContainer(
      borderRadius: BorderRadius.circular(borderRadius),
      alignment: alignment,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      padding: padding ?? const EdgeInsets.all(20),
      height: height,
      width: width,
      color: color ?? (light ? Colors.white : kBorderContainerBgDark),
      child: child,
    );

    return container;
  }
}
