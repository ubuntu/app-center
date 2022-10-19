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
import 'package:software/store_app/common/app_format.dart';
import 'package:software/store_app/common/drop_down_decoration.dart';

class AppFormatButton extends StatelessWidget {
  const AppFormatButton({
    super.key,
    required this.onPressed,
    required this.appFormat,
  });

  final void Function(AppFormat appFormat) onPressed;
  final AppFormat appFormat;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton(
          initialValue: appFormat,
          itemBuilder: (context) {
            return [
              for (var appFormat in AppFormat.values)
                PopupMenuItem(
                  value: appFormat,
                  onTap: () => onPressed(appFormat),
                  child: Text(
                    appFormat.localize(context.l10n),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
            ];
          },
          child: DropDownDecoration(
            child: Text(appFormat.localize(context.l10n)),
          ),
        ),
      ),
    );
  }
}
