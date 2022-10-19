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
import 'package:software/store_app/common/drop_down_decoration.dart';
import 'package:software/store_app/common/snap_section.dart';

class SectionDropdown extends StatelessWidget {
  const SectionDropdown({
    // ignore: unused_element
    super.key,
    required this.value,
    this.onChanged,
  });

  final SnapSection value;
  final Function(SnapSection?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<SnapSection>(
          tooltip: context.l10n.filterSnaps,
          splashRadius: 20,
          onSelected: onChanged,
          initialValue: SnapSection.all,
          itemBuilder: (context) {
            return [
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
                        ),
                      )
                    ],
                  ),
                )
            ];
          },
          child: DropDownDecoration(child: Text(value.localize(context.l10n))),
        ),
      ),
    );
  }
}
