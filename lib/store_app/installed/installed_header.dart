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
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_format.dart';
import 'package:software/store_app/common/app_format_popup.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/packagekit/packagekit_filter_button.dart';
import 'package:software/store_app/common/snap/snap_sort_popup.dart';
import 'package:software/store_app/installed/installed_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class InstalledHeader extends StatelessWidget {
  const InstalledHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<InstalledModel>();
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
              appFormat: model.appFormat,
              onSelected: model.setAppFormat,
            ),
            if (model.appFormat == AppFormat.packageKit)
              PackageKitFilterButton(
                onTap: (value, filter) => model.handleFilter(value, filter),
                filters: model.packageKitFilters,
                lockInstalled: true,
              ),
            if (model.appFormat == AppFormat.snap)
              SnapSortPopup(
                value: model.snapSort,
                onSelected: (value) => model.setSnapSort(value),
              ),
            if (model.appFormat == AppFormat.snap)
              YaruIconButton(
                onPressed: () =>
                    model.loadSnapsWithUpdates = !model.loadSnapsWithUpdates,
                isSelected: model.loadSnapsWithUpdates,
                icon: const Icon(Icons.upgrade_rounded),
                tooltip: context.l10n.updateAvailable,
              ),
            if (model.appFormat == AppFormat.snap &&
                model.loadSnapsWithUpdates &&
                model.localSnaps.isNotEmpty)
              ElevatedButton(
                onPressed: model.busy
                    ? null
                    : () => model.updateAll(
                          doneMessage: context.l10n.done,
                        ),
                child: Text(context.l10n.refresh),
              )
          ],
        ),
      ),
    );
  }
}
