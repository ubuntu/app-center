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
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapInstallationControls extends StatelessWidget {
  const SnapInstallationControls({
    super.key,
    required this.appChangeInProgress,
    required this.appIsInstalled,
    required this.remove,
    required this.refresh,
    required this.install,
    this.open,
  });

  final bool appChangeInProgress;
  final bool appIsInstalled;
  final Function() remove;
  final Function() refresh;
  final Function() install;
  final Function()? open;

  @override
  Widget build(BuildContext context) {
    if (appChangeInProgress) {
      return const SizedBox(
        height: 25,
        child: YaruCircularProgressIndicator(
          strokeWidth: 3,
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (open != null && appIsInstalled)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                onPressed: open,
                child: Text(context.l10n.open),
              ),
            ),
          if (appIsInstalled)
            OutlinedButton(
              onPressed: remove,
              child: Text(
                context.l10n.remove,
                style: appChangeInProgress
                    ? TextStyle(color: Theme.of(context).disabledColor)
                    : null,
              ),
            ),
          const SizedBox(
            width: 10,
          ),
          if (appIsInstalled)
            OutlinedButton(
              onPressed: refresh,
              child: Text(context.l10n.refresh),
            )
          else
            ElevatedButton(
              onPressed: appChangeInProgress ? null : install,
              child: Text(context.l10n.install),
            ),
        ],
      );
    }
  }
}
