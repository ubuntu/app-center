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
import 'package:software/store_app/common/app_format_popup.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/my_apps/my_apps_model.dart';

class MyAppsHeader extends StatelessWidget {
  const MyAppsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyAppsModel>();
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
          ],
        ),
      ),
    );
  }
}
