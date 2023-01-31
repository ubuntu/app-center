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
import 'package:snapd/snapd.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/constants.dart';

import '../app_banner.dart';

class SnapGrid extends StatelessWidget {
  const SnapGrid({super.key, required this.snaps});

  final List<Snap> snaps;

  @override
  Widget build(BuildContext context) {
    if (snaps.isEmpty) {
      return const SizedBox.shrink();
    }
    return GridView.builder(
      padding: kGridPadding,
      gridDelegate: kGridDelegate,
      shrinkWrap: true,
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps.elementAt(index);
        return AppBanner(
          appFinding: MapEntry<String, AppFinding>(
            snap.name,
            AppFinding(snap: snap),
          ),
          showSnap: true,
          showPackageKit: false,
        );
      },
    );
  }
}
