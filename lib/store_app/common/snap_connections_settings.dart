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
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapConnectionsSettings extends StatelessWidget {
  const SnapConnectionsSettings({
    super.key,
    this.headerTextStyle,
    this.isExpanded = true,
  });

  final TextStyle? headerTextStyle;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    return YaruExpandable(
      isExpanded: isExpanded,
      header: Text(
        context.l10n.connections,
        style: Theme.of(context).textTheme.headline6,
      ),
      expandIcon: const Icon(YaruIcons.pan_end),
      child: Column(
        children: [
          if (model.plugs != null && model.plugs!.isNotEmpty)
            for (final plugEntry in model.plugs!.entries)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plugEntry.key.interface ?? ''),
                    Switch(
                      value: plugEntry.value,
                      onChanged: model.snapChangeInProgress
                          ? null
                          : (value) {
                              if (plugEntry.key.interface == null) return;
                              model.toggleConnection(
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
      ),
    );
  }
}
