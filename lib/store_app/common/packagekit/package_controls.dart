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
import '../../../l10n/l10n.dart';
import '../../../package_state.dart';

class PackageControls extends StatelessWidget {
  const PackageControls({
    super.key,
    required this.isInstalled,
    required this.install,
    required this.remove,
    required this.packageState,
  });

  final bool? isInstalled;
  final VoidCallback install;
  final VoidCallback remove;
  final PackageState packageState;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (isInstalled == null)
          const SizedBox.shrink()
        else if (isInstalled!)
          OutlinedButton(
            onPressed: packageState != PackageState.ready ? null : remove,
            child: Text(context.l10n.remove),
          )
        else
          ElevatedButton(
            onPressed: packageState != PackageState.ready ? null : install,
            child: Text(context.l10n.install),
          )
      ],
    );
  }
}
