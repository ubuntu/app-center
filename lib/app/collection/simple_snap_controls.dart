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
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/collection/simple_snap_model.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/snapd_change_x.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SimpleSnapControls extends StatelessWidget {
  const SimpleSnapControls({
    super.key,
    required this.hasUpdate,
    required this.enabled,
  });

  static Widget create({
    required BuildContext context,
    required Snap snap,
    required bool hasUpdate,
    required bool enabled,
  }) {
    return ChangeNotifierProvider<SimpleSnapModel>(
      create: (_) {
        return SimpleSnapModel(
          getService<SnapService>(),
          getService<PrivilegedDesktopLauncher>(),
          snap: snap,
        )..init();
      },
      child: SimpleSnapControls(
        hasUpdate: hasUpdate,
        enabled: enabled,
      ),
    );
  }

  final bool hasUpdate;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SimpleSnapModel>();
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: model.change != null
          ? [
              SizedBox(
                height: 20,
                child: YaruCircularProgressIndicator(
                  strokeWidth: 3,
                  value: model.change?.progress,
                ),
              ),
              if (model.change != null) ...[
                Text(
                  getChangeMessage(
                    context: context,
                    changeKind: model.change!.kind,
                  ),
                ),
                if (model.change!.kind != 'remove-snap')
                  OutlinedButton(
                    onPressed: model.abortChange,
                    child: Text(context.l10n.cancel),
                  ),
              ]
            ]
          : [
              if (hasUpdate)
                OutlinedButton(
                  onPressed: model.change == null && enabled
                      ? () => model.refresh(context.l10n.done)
                      : null,
                  child: Text(
                    context.l10n.updateButton,
                    style: enabled
                        ? TextStyle(
                            color: light ? kGreenLight : kGreenDark,
                          )
                        : null,
                  ),
                ),
              if (model.isLaunchable && enabled)
                OutlinedButton(
                  onPressed: model.open,
                  child: Text(
                    context.l10n.open,
                  ),
                ),
              OutlinedButton(
                onPressed: enabled
                    ? () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                context.l10n
                                    .removePackage(model.snap.apps.first.name),
                              ),
                              content: Text(
                                context.l10n.confirmRemove,
                              ),
                              actions: <Widget>[
                                OutlinedButton(
                                  child: Text(context.l10n.cancel),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                  child: Text(context.l10n.remove),
                                  onPressed: () {
                                    model.remove(context.l10n.done);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    : null,
                child: Text(context.l10n.remove),
              ),
            ],
    );
  }

  String getChangeMessage({
    required BuildContext context,
    required String? changeKind,
  }) =>
      switch (changeKind) {
        'install-snap' => context.l10n.installing,
        'remove-snap' => context.l10n.removing,
        'refresh-snap' => context.l10n.refreshing,
        'connect-snap' => context.l10n.changingPermissions,
        'disconnect-snap' => context.l10n.changingPermissions,
        _ => ''
      };
}
