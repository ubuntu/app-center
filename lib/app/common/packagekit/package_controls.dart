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
import 'package:software/services/packagekit/package_state.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageControls extends StatelessWidget {
  const PackageControls({
    super.key,
    required this.isInstalled,
    required this.install,
    required this.remove,
    required this.packageState,
    required this.versionChanged,
    this.hasDependencies,
    this.showDeps,
  });

  final bool? isInstalled;
  final VoidCallback install;
  final VoidCallback remove;
  final PackageState packageState;
  final bool? versionChanged;
  final bool? hasDependencies;
  final VoidCallback? showDeps;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: packageState == PackageState.processing
          ? [
              const SizedBox(
                height: 20,
                child: YaruCircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
              Text(context.l10n.processing),
            ]
          : [
              if (isInstalled == true)
                OutlinedButton(
                  onPressed: packageState != PackageState.ready ? null : remove,
                  child: Text(context.l10n.remove),
                ),
              if (isInstalled == false)
                ElevatedButton(
                  onPressed: packageState != PackageState.ready
                      ? null
                      : (hasDependencies == true ? showDeps : install),
                  child: Text(context.l10n.install),
                ),
              if (isInstalled == true && versionChanged == true)
                ElevatedButton(
                  onPressed:
                      packageState != PackageState.ready ? null : install,
                  child: Text(context.l10n.refresh),
                ),
              const SizedBox.shrink()
            ],
    );
  }
}
