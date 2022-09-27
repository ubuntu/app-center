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
import 'package:software/store_app/common/snap_channel_button.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapControls extends StatelessWidget {
  const SnapControls({
    Key? key,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  final Axis direction;
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    if (model.appChangeInProgress) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: YaruCircularProgressIndicator(
          strokeWidth: 3,
        ),
      );
    }

    return Wrap(
      direction: direction,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (model.snapIsInstalled)
          OutlinedButton(
            onPressed: model.remove,
            child: Text(context.l10n.remove),
          ),
        if (model.snapIsInstalled)
          ElevatedButton(
            onPressed: model.selectedChannelVersion != model.version
                ? model.refresh
                : null,
            child: Text(
              context.l10n.refresh,
            ),
          )
        else
          ElevatedButton(
            onPressed: model.install,
            child: Text(
              context.l10n.install,
            ),
          ),
        if (model.selectableChannels.isNotEmpty &&
            model.selectableChannels.length > 1)
          const SnapChannelPopupButton(),
      ],
    );
  }
}
