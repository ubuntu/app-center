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
import 'package:software/app/common/app_format.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppFormatPopup extends StatelessWidget {
  const AppFormatPopup({
    super.key,
    required this.onSelected,
    required this.appFormat,
    required this.enabledAppFormats,
  });

  final void Function(AppFormat appFormat) onSelected;
  final AppFormat appFormat;
  final Set<AppFormat> enabledAppFormats;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton(
      initialValue: appFormat,
      tooltip: context.l10n.appFormat,
      itemBuilder: (v) => [
        for (var appFormat in enabledAppFormats)
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

class MultiAppFormatPopup extends StatelessWidget {
  const MultiAppFormatPopup({
    super.key,
    required this.selectedAppFormats,
    required this.enabledAppFormats,
    required this.onTap,
  });

  final Set<AppFormat> selectedAppFormats;
  final Set<AppFormat> enabledAppFormats;
  final Function(AppFormat appFormat) onTap;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton<AppFormat>(
      tooltip: context.l10n.appFormat,
      onSelected: (v) => onTap(v),
      itemBuilder: (context) {
        return [
          for (final appFormat in enabledAppFormats)
            YaruCheckedPopupMenuItem<AppFormat>(
              padding: EdgeInsets.zero,
              value: appFormat,
              checked: selectedAppFormats.contains(appFormat),
              child: Text(
                appFormat.localize(context.l10n),
              ),
            ),
        ];
      },
      child: Text(
        selectedAppFormats.length == AppFormat.values.length
            ? context.l10n.allPackageTypes
            : selectedAppFormats.first.localize(context.l10n),
      ),
    );
  }
}
