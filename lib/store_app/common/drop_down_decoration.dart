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

class DropDownDecoration extends StatelessWidget {
  const DropDownDecoration({
    Key? key,
    required this.child,
    this.childPadding = const EdgeInsets.symmetric(horizontal: 5),
  }) : super(key: key);

  final Widget child;
  final EdgeInsets childPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: childPadding,
              child: child,
            ),
            const SizedBox(
              height: 40,
              child: Icon(
                YaruIcons.pan_down,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
