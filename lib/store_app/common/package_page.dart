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
import 'package:software/store_app/common/app_description.dart';
import 'package:software/store_app/common/app_header.dart';
import 'package:software/store_app/common/app_infos.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/media_tile.dart';
import 'package:software/store_app/common/package_controls.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:software/store_app/common/page_layouts.dart';
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
    final media = model.screenshotUrls;
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final windowHeight = windowSize.height;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1400;
    final isWindowWide = windowWidth > 1400;

    final mediaDescriptionAndConnections = [
      if (media.isNotEmpty)
        BorderContainer(
          child: YaruCarousel(
            nextIcon: const Icon(YaruIcons.go_next),
            previousIcon: const Icon(YaruIcons.go_previous),
            navigationControls: media.length > 1,
            viewportFraction: isWindowWide ? 0.5 : 1,
            height: windowHeight / 3,
            children: [for (final url in media) MediaTile(url: url)],
          ),
        ),
      BorderContainer(
        child: AppDescription(description: model.description),
      ),
    ];

    final headerData = AppHeaderData(
      confinementName: context.l10n.classic,
      icon: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: model.isInstalled ? () => model.open(widget.id.name) : null,
        child: YaruSafeImage(
          url: model.iconUrl,
          fallBackIconData: YaruIcons.snapcraft,
        ),
      ),
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
      controls: PackageControls(
        isInstalled: model.isInstalled,
        packageState: model.packageState!,
        remove: () => model.remove(packageId: widget.id),
        install: () => model.install(
          packageId: widget.id,
        ),
      ),
    );

    final normalWindowAppHeader = BorderContainer(
      child: BannerAppHeader(
        headerData: headerData,
      ),
    );

    final wideWindowAppHeader = BorderContainer(
      width: 480,
      child: PageAppHeader(
        headerData: headerData,
      ),
    );

    final narrowWindowAppHeader = BorderContainer(
      height: 650,
      child: PageAppHeader(
        headerData: headerData,
      ),
    );

    final normalWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        normalWindowAppHeader,
        BorderContainer(
          child: AppInfos(
            strict: false,
            confinementName: context.l10n.classic,
            license: model.license,
            installDate: '',
            installDateIsoNorm: '',
            version: widget.id.version,
          ),
        ),
        for (final part in mediaDescriptionAndConnections) part
      ],
    );

    final wideWindowLayout = PanedPageLayout(
      leftChild: wideWindowAppHeader,
      rightChildren: mediaDescriptionAndConnections,
      windowSize: windowSize,
    );

    final narrowWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        narrowWindowAppHeader,
        for (final part in mediaDescriptionAndConnections) part
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id.name),
        leading: InkWell(
          onTap: widget.onPop,
          child: const Icon(YaruIcons.go_previous),
        ),
      ),
      body: isWindowWide
          ? wideWindowLayout
          : isWindowNormalSized
              ? normalWindowLayout
              : narrowWindowLayout,
    );
  }
}
