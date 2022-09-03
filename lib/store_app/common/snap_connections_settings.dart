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
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapConnectionsSettings extends StatelessWidget {
  const SnapConnectionsSettings({super.key, required this.connections});

  final Map<String, SnapConnection> connections;

  @override
  Widget build(BuildContext context) {
    return YaruExpandable(
      isExpanded: false,
      header: Text(
        context.l10n.connections,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      expandIcon: const Icon(YaruIcons.pan_end),
      child: Column(
        children: [
          if (connections.isNotEmpty)
            for (final connection in connections.entries)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(connection.key),
                    Switch(
                      value: true,
                      onChanged: (v) {},
                    )
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
