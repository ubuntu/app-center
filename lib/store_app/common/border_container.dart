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

/// A [Container] with predefined [Decoration].
/// The [Decoration] has a [Border] with [Divider]'s color.
/// The [BorderContainer] wraps its [child] in a [Padding]
/// which defaults to 20 on all sides
class BorderContainer extends StatelessWidget {
  const BorderContainer({
    super.key,
    this.height,
    this.width,
    this.childPadding,
    this.child,
    this.borderRadius = 10,
    this.alignment,
    this.color,
    this.foregroundDecoration,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.containerPadding,
  });

  /// Forwarded to [Container]
  final double? height;

  /// Forwarded to [Container]
  final double? width;

  /// The [Padding] which the [child] is surrounded by. Defaults to 20
  /// on all sides.
  final EdgeInsets? childPadding;

  /// Forwarded to [Container]
  final EdgeInsets? containerPadding;

  /// Forwarded to [Container]
  final Widget? child;

  /// The radius added to the BoxDecoration of the [Container],
  /// default value is 10 on all edges.
  final double borderRadius;

  /// Forwarded to [Container]
  final AlignmentGeometry? alignment;

  /// Forwarded to [Container]
  final Color? color;

  /// The decoration to paint in front of the [child], Forwarded to [Container]
  final Decoration? foregroundDecoration;

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

  @override
  Widget build(BuildContext context) {
    final container = Container(
      alignment: alignment,
      color: color,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      padding: containerPadding ?? const EdgeInsets.all(20),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: child,
    );

    return childPadding != null
        ? Padding(
            padding: childPadding!,
            child: container,
          )
        : container;
  }
}
