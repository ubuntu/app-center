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
import 'package:software/store_app/common/snap/snap_sort.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapSortPopup extends StatelessWidget {
  const SnapSortPopup({
    Key? key,
    required this.value,
    required this.onSelected,
    this.enabled = true,
  }) : super(key: key);
  final SnapSort value;
  final void Function(SnapSort value) onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton(
      enabled: enabled,
      initialValue: value,
      onSelected: onSelected,
      tooltip: context.l10n.sortBy,
      itemBuilder: (v) => [
        for (var appFormat in SnapSort.values)
          PopupMenuItem(
            value: appFormat,
            onTap: () => onSelected(appFormat),
            child: Text(
              appFormat.localize(context.l10n),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
      child: Text('${context.l10n.sortBy}: ${value.localize(context.l10n)}'),
    );
  }
}
