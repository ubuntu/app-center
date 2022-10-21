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
import 'package:software/store_app/common/snap/snap_section.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapSectionPopup extends StatelessWidget {
  const SnapSectionPopup({
    // ignore: unused_element
    super.key,
    required this.value,
    required this.onSelected,
  });

  final SnapSection value;
  final Function(SnapSection) onSelected;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton(
      initialValue: value,
      onSelected: onSelected,
      tooltip: context.l10n.filterSnaps,
      items: [
        for (final section in SnapSection.values)
          PopupMenuItem(
            value: section,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: 20,
                  child: Icon(
                    snapSectionToIcon[section],
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                    size: 18,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    section.localize(
                      context.l10n,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              ],
            ),
          )
      ],
      child: Text(value.localize(context.l10n)),
    );
  }
}
