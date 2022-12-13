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
import 'package:provider/provider.dart';
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';

class PackageInstallerPage {
  static Widget create({
    String? path,
    required BuildContext context,
    PackageKitPackageId? packageId,
    AppstreamComponent? appstream,
  }) {
    return ChangeNotifierProvider(
      create: (context) => PackageModel(
        path: path,
        service: getService<PackageService>(),
        packageId: packageId,
        appstream: appstream,
      ),
      child: PackagePage(
        appstream: appstream,
      ),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.packageInstaller);

  static Widget createIcon(BuildContext context, bool selected) =>
      const Icon(YaruIcons.insert_object);

  static String createTooltip(BuildContext context) =>
      context.l10n.packageInstaller;
}
