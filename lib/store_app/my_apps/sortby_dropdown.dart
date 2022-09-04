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
import 'package:software/store_app/my_apps/sort_by.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SortByDropdown extends StatelessWidget {
  const SortByDropdown({Key? key, required this.value, required this.onChanged})
      : super(key: key);
  final SortBy value;
  final Function(SortBy?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<SortBy>(
      icon: const Icon(YaruIcons.pan_down),
      value: value,
      items: [
        for (final sortBy in SortBy.values)
          DropdownMenuItem(
            value: sortBy,
            child: Text('Sort by: ${sortBy.localize(context.l10n)}'),
          ),
      ],
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(10),
    );
  }
}
