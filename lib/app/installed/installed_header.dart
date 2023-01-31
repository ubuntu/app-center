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
import 'package:packagekit/packagekit.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_format_popup.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/packagekit/packagekit_filter_button.dart';
import 'package:software/app/common/snap/snap_sort.dart';
import 'package:software/app/common/snap/snap_sort_popup.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class InstalledHeader extends StatelessWidget {
  const InstalledHeader({
    super.key,
    required this.appFormat,
    required this.enabledAppFormats,
    required this.setAppFormat,
    required this.handleFilter,
    required this.packageKitFilters,
    required this.snapSort,
    required this.setSnapSort,
    required this.setLoadSnapsWithUpdates,
    required this.loadSnapsWithUpdates,
  });

  final AppFormat appFormat;
  final Set<AppFormat> enabledAppFormats;
  final void Function(AppFormat) setAppFormat;
  final void Function(bool, PackageKitFilter) handleFilter;
  final Set<PackageKitFilter> packageKitFilters;
  final SnapSort snapSort;
  final void Function(SnapSort) setSnapSort;
  final void Function(bool) setLoadSnapsWithUpdates;
  final bool loadSnapsWithUpdates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kHeaderPadding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          runAlignment: WrapAlignment.start,
          spacing: 10,
          children: [
            AppFormatPopup(
              appFormat: appFormat,
              enabledAppFormats: enabledAppFormats,
              onSelected: setAppFormat,
            ),
            if (appFormat == AppFormat.packageKit)
              PackageKitFilterButton(
                onTap: (value, filter) => handleFilter(value, filter),
                filters: packageKitFilters,
                lockInstalled: true,
              ),
            if (appFormat == AppFormat.snap)
              SnapSortPopup(
                value: snapSort,
                onSelected: (value) => setSnapSort(value),
              ),
            if (appFormat == AppFormat.snap)
              YaruIconButton(
                onPressed: () => setLoadSnapsWithUpdates(!loadSnapsWithUpdates),
                isSelected: loadSnapsWithUpdates,
                icon: const Icon(Icons.upgrade_rounded),
                tooltip: context.l10n.updateAvailable,
              ),
          ],
        ),
      ),
    );
  }
}
