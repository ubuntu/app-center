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
import 'package:software/store_app/common/constants.dart';

class BorderContainer extends StatelessWidget {
  const BorderContainer({
    super.key,
    this.height,
    this.width,
    this.padding,
    this.child,
  });

  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: const EdgeInsets.all(pagePadding),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: child,
    );

    return padding != null
        ? Padding(
            padding: padding!,
            child: container,
          )
        : container;
  }
}
