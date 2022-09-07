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
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapConnectionsSettings extends StatelessWidget {
  const SnapConnectionsSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    return YaruExpandable(
      isExpanded: false,
      header: Text(
        context.l10n.connections,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      expandIcon: const Icon(YaruIcons.pan_end),
      child: Column(
        children: [
          for (final plug in model.nicePlugs)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plug.interface ?? ''),
                  Switch(
                    value: true,
                    onChanged: (v) => model.disconnect(
                      con: SnapConnection(
                        slot: plug.connections.first,
                        plug: plug,
                        interface: plug.interface!,
                      ),
                    ),
                  )
                ],
              ),
            ),
          for (final plug in model.badPlugs)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plug.interface ?? ''),
                  Switch(
                    value: false,
                    onChanged: (v) => model.connect(
                      plug: plug.plug,
                      snap: model.huskSnapName,
                      slot: '',
                      slotSnap: model.huskSnapName,
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
