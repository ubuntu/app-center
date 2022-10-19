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

class AppFormatButton extends StatelessWidget {
  const AppFormatButton({
    super.key,
    this.onPressed,
    required this.appFormat,
    required this.selected,
  });

  final void Function()? onPressed;
  final AppFormat appFormat;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            appFormatToIconData[appFormat],
            size: 15,
            color: color,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            appFormat.localize(context.l10n),
            style: TextStyle(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
