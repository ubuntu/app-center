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
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapConnectionsSettings extends StatelessWidget {
  const SnapConnectionsSettings({
    super.key,
    this.headerTextStyle,
    this.isExpanded = true,
    required this.snapChangeInProgress,
    required this.plugs,
    required this.toggleConnection,
  });

  final TextStyle? headerTextStyle;
  final bool isExpanded;
  final bool snapChangeInProgress;
  final Map<SnapPlug, bool> plugs;
  final void Function({
    required String interface,
    required SnapPlug snap,
    required bool value,
  }) toggleConnection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (plugs.isNotEmpty)
          for (final plugEntry in plugs.entries)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plugEntry.key.interface ?? ''),
                  YaruSwitch(
                    value: plugEntry.value,
                    onChanged: snapChangeInProgress
                        ? null
                        : (value) {
                            if (plugEntry.key.interface == null) return;
                            toggleConnection(
                              interface: plugEntry.key.interface!,
                              snap: plugEntry.key,
                              value: value,
                            );
                          },
                  )
                ],
              ),
            ),
      ],
    );
  }
}
