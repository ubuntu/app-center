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
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_state.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageControls extends StatelessWidget {
  const PackageControls({
    super.key,
    this.showDeps,
  });

  final VoidCallback? showDeps;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: model.packageState == PackageState.processing
          ? [
              const SizedBox(
                height: 40,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: YaruCircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              ),
              Text(context.l10n.processing),
            ]
          : [
              if (model.isInstalled == true)
                OutlinedButton(
                  onPressed: model.packageState != PackageState.ready
                      ? null
                      : model.remove,
                  child: Text(context.l10n.remove),
                ),
              if (model.isInstalled == false)
                ElevatedButton(
                  onPressed: model.packageState != PackageState.ready
                      ? null
                      : (model.missingDependencies.isNotEmpty
                          ? showDeps
                          : model.install),
                  child: Text(context.l10n.install),
                ),
              if (model.isInstalled == true && model.versionChanged == true)
                ElevatedButton(
                  onPressed: model.packageState != PackageState.ready
                      ? null
                      : model.install,
                  child: Text(context.l10n.update),
                ),
              const SizedBox.shrink()
            ],
    );
  }
}
