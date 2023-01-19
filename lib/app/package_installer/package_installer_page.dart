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

import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageInstallerPage {
  static Widget create({
    String? debPath,
    String? snapName,
    required BuildContext context,
    PackageKitPackageId? packageId,
    AppstreamComponent? appstream,
  }) {
    assert((debPath != null) != (snapName != null));
    if (debPath != null) {
      return PackagePage.create(
        context: context,
        path: debPath,
        appstream: appstream,
        packageId: packageId,
      );
    }
    return FutureBuilder<Snap?>(
      future: getService<SnapService>().findSnapByName(snapName!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SnapPage.create(context: context, snap: snapshot.data!);
        }
        return const Center(child: YaruCircularProgressIndicator());
      },
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.packageInstaller);

  static Widget createIcon(BuildContext context, bool selected) =>
      const Icon(YaruIcons.insert_object);

  static String createTooltip(BuildContext context) =>
      context.l10n.packageInstaller;
}
