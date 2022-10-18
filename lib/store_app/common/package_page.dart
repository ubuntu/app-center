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
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/app_data.dart';
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/app_page.dart';
import 'package:software/store_app/common/package_controls.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({
    super.key,
    required this.noUpdate,
    required this.id,
    required this.installedId,
    required this.onPop,
  });

  final bool noUpdate;
  final PackageKitPackageId id;
  final PackageKitPackageId installedId;
  final VoidCallback onPop;

  static Widget create({
    required BuildContext context,
    required PackageKitPackageId id,
    required PackageKitPackageId installedId,
    bool noUpdate = true,
    required final VoidCallback onPop,
  }) {
    return ChangeNotifierProvider(
      create: (context) => PackageModel(getService<PackageService>()),
      child: PackagePage(
        onPop: onPop,
        noUpdate: noUpdate,
        id: id,
        installedId: installedId,
      ),
    );
  }

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  @override
  void initState() {
    context
        .read<PackageModel>()
        .init(update: !widget.noUpdate, packageId: widget.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();

    final appData = AppData(
      confinementName: context.l10n.classic,
      installDate: '',
      installDateIsoNorm: '',
      license: model.license,
      strict: false,
      verified: false,
      publisherName: context.l10n.website,
      website: model.url,
      summary: model.summary,
      title: widget.id.name,
      version: widget.id.version,
      screenShotUrls: model.screenshotUrls,
      description: model.description,
    );
    return AppPage(
      appData: appData,
      onPop: widget.onPop,
      permissionContainer: const SizedBox(),
      icon: AppIcon(
        iconUrl: model.iconUrl,
        fallBackIconData: YaruIcons.debian,
        size: 150,
      ),
      controls: PackageControls(
        isInstalled: model.isInstalled,
        packageState: model.packageState!,
        remove: () => model.remove(packageId: widget.id),
        install: () => model.install(
          packageId: widget.id,
        ),
      ),
    );
  }
}
