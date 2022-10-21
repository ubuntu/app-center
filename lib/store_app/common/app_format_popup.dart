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
import 'package:yaru_widgets/yaru_widgets.dart';

class AppFormatPopup extends StatelessWidget {
  const AppFormatPopup({
    super.key,
    required this.onSelected,
    required this.appFormat,
  });

  final void Function(AppFormat appFormat) onSelected;
  final AppFormat appFormat;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton(
      initialValue: appFormat,
      tooltip: context.l10n.appFormat,
      items: [
        for (var appFormat in AppFormat.values)
          PopupMenuItem(
            value: appFormat,
            onTap: () => onSelected(appFormat),
            child: Text(
              appFormat.localize(context.l10n),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
      ],
      onSelected: onSelected,
      child: Text(appFormat.localize(context.l10n)),
    );
  }
}
