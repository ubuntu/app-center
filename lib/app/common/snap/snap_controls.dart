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

import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/common/snap/snap_channel_button.dart';
import 'package:software/app/common/snap/snap_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapd_change_x.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapControls extends StatelessWidget {
  const SnapControls({
    super.key,
    this.direction = Axis.horizontal,
    this.appstream,
  });

  final Axis direction;
  final AppstreamComponent? appstream;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return Wrap(
      direction: direction,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: model.snapChangeInProgress
          ? [
              SizedBox(
                height: 20,
                child: YaruCircularProgressIndicator(
                  strokeWidth: 3,
                  value: model.change?.progress,
                ),
              ),
              if (model.change != null)
                Text(
                  getChangeMessage(
                    context: context,
                    changeKind: model.change!.kind,
                  ),
                ),
            ]
          : [
              if (model.selectableChannels.isNotEmpty &&
                  model.selectableChannels.length > 1 &&
                  appstream != null)
                const SnapChannelPopupButton(),
              if (model.snapIsInstalled)
                OutlinedButton(
                  onPressed: model.remove,
                  child: Text(context.l10n.remove),
                ),
              if (model.snapIsInstalled)
                ElevatedButton(
                  onPressed:
                      model.isUpdateAvailable() && !model.snapChangeInProgress
                          ? model.refresh
                          : null,
                  child: Text(
                    context.l10n.updateButton,
                  ),
                )
              else
                ElevatedButton(
                  onPressed: model.install,
                  child: Text(
                    context.l10n.install,
                  ),
                ),
            ],
    );
  }

  String getChangeMessage({
    required BuildContext context,
    required String? changeKind,
  }) {
    switch (changeKind) {
      case 'install-snap':
        return context.l10n.installing;
      case 'remove-snap':
        return context.l10n.removing;
      case 'refresh-snap':
        return context.l10n.refreshing;
      case 'connect-snap':
        return context.l10n.changingPermissions;
      case 'disconnect-snap':
        return context.l10n.changingPermissions;
      default:
        return '';
    }
  }
}
