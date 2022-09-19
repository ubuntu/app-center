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
import 'package:software/package_state.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/app_description.dart';
import 'package:software/store_app/common/app_infos.dart';
import 'package:software/store_app/common/app_media.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/one_column_app_header.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:software/store_app/common/page_layouts.dart';
import 'package:software/store_app/common/two_column_app_header.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    final rightChildren = [
      const BorderContainer(
        padding: EdgeInsets.only(
          bottom: pagePadding,
          right: pagePadding,
        ),
        // TODO: empty media, see: https://github.com/ubuntu-flutter-community/software/issues/128

        child: AppMedia(media: []),
      ),
      BorderContainer(
        padding: const EdgeInsets.only(
          bottom: pagePadding,
          right: pagePadding,
        ),
        child: AppDescription(description: model.description),
      ),
    ];

    final oneColumnAppHeader = BorderContainer(
      padding: const EdgeInsets.all(pagePadding),
      child: OneColumnAppHeader(
        confinementName: context.l10n.classic,
        icon: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: model.isInstalled ? () => model.open(widget.id.name) : null,
          child: const YaruSafeImage(
            url: '',
            fallBackIconData: YaruIcons.package_deb,
          ),
        ),
        installDate: '',
        installDateIsoNorm: '',
        license: model.license,
        strict: false,
        verified: false,
        publisherName: '',
        website: model.url,
        summary: model.summary,
        title: widget.id.name,
        version: widget.id.version,
        controls: Row(
          children: [
            if (model.isInstalled)
              OutlinedButton(
                onPressed: model.packageState != PackageState.ready
                    ? null
                    : () => model.remove(packageId: widget.id),
                child: Text(context.l10n.remove),
              ),
            if (!model.isInstalled)
              ElevatedButton(
                onPressed: model.packageState != PackageState.ready
                    ? null
                    : () => model.install(packageId: widget.id),
                child: Text(context.l10n.install),
              ),
          ],
        ),
      ),
    );

    final twoColumnAppHeader = BorderContainer(
      padding: const EdgeInsets.all(pagePadding),
      width: 500,
      child: TwoColumnAppHeader(
        confinementName: context.l10n.classic,
        icon: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: model.isInstalled ? () => model.open(widget.id.name) : null,
          child: const YaruSafeImage(
            url: '',
            fallBackIconData: YaruIcons.package_deb,
          ),
        ),
        installDate: '',
        installDateIsoNorm: '',
        license: model.license,
        strict: false,
        verified: false,
        publisherName: '',
        website: model.url,
        summary: model.summary,
        title: widget.id.name,
        version: widget.id.version,
        controls: Row(
          children: [
            if (model.isInstalled)
              OutlinedButton(
                onPressed: model.packageState != PackageState.ready
                    ? null
                    : () => model.remove(packageId: widget.id),
                child: Text(context.l10n.remove),
              ),
            if (!model.isInstalled)
              ElevatedButton(
                onPressed: model.packageState != PackageState.ready
                    ? null
                    : () => model.install(packageId: widget.id),
                child: Text(context.l10n.install),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id.name),
        leading: InkWell(
          onTap: widget.onPop,
          child: const Icon(YaruIcons.go_previous),
        ),
      ),
      body: screenWidth < 1001
          ? NarrowPageLayout(
              children: [
                oneColumnAppHeader,
                BorderContainer(
                  padding: const EdgeInsets.only(
                    bottom: pagePadding,
                    right: pagePadding,
                    left: pagePadding,
                  ),
                  child: AppInfos(
                    strict: false,
                    confinementName: context.l10n.classic,
                    license: model.license,
                    installDate: '',
                    installDateIsoNorm: '',
                    version: widget.id.version,
                  ),
                ),
                for (final rightChild in rightChildren)
                  Padding(
                    padding: const EdgeInsets.only(left: pagePadding),
                    child: rightChild,
                  )
              ],
            )
          : WidePageLayout(
              leftChild: twoColumnAppHeader,
              rightChildren: rightChildren,
            ),
    );
  }
}
