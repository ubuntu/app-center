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

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class InfoColumn extends StatelessWidget {
  const InfoColumn({
    Key? key,
    required this.header,
    required this.child,
    required this.tooltipMessage,
    this.childWidth,
  }) : super(key: key);

  final String header;
  final String tooltipMessage;
  final Widget child;
  final double? childWidth;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            header,
            overflow: TextOverflow.ellipsis,
            style: headerStyle,
          ),
          SizedBox(
            width: childWidth ?? 100,
            child: child,
          ),
        ],
      ),
    );
  }
}
