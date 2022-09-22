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
import 'package:software/store_app/common/app_data.dart';
import 'package:software/store_app/common/app_description.dart';
import 'package:software/store_app/common/app_header.dart';
import 'package:software/store_app/common/app_infos.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/media_tile.dart';
import 'package:software/store_app/common/page_layouts.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.appData,
    required this.onPop,
    required this.icon,
    required this.permissionContainer,
    required this.controls,
    this.subControlPageHeader,
    this.subBannerHeader,
  });

  final AppData appData;
  final VoidCallback onPop;
  final Widget icon;
  final Widget permissionContainer;
  final Widget controls;
  final Widget? subControlPageHeader;
  final Widget? subBannerHeader;

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final windowHeight = windowSize.height;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1400;
    final isWindowWide = windowWidth > 1400;

    final mediaDescriptionAndConnections = [
      if (appData.screenShotUrls.isNotEmpty)
        BorderContainer(
          child: YaruCarousel(
            nextIcon: const Icon(YaruIcons.go_next),
            previousIcon: const Icon(YaruIcons.go_previous),
            navigationControls: appData.screenShotUrls.length > 1,
            viewportFraction: isWindowWide ? 0.5 : 1,
            height: windowHeight / 3,
            children: [
              for (final url in appData.screenShotUrls) MediaTile(url: url)
            ],
          ),
        ),
      BorderContainer(
        child: AppDescription(description: appData.description),
      ),
      permissionContainer,
    ];

    final normalWindowAppHeader = BorderContainer(
      child: BannerAppHeader(
        headerData: appData,
        controls: controls,
        icon: icon,
      ),
    );

    final wideWindowAppHeader = BorderContainer(
      width: 480,
      child: PageAppHeader(
        headerData: appData,
        icon: icon,
        controls: controls,
        subControls: subControlPageHeader,
      ),
    );

    final narrowWindowAppHeader = BorderContainer(
      height: 700,
      child: PageAppHeader(
        headerData: appData,
        icon: icon,
        controls: controls,
        subControls: subControlPageHeader,
      ),
    );

    final normalWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        normalWindowAppHeader,
        if (subBannerHeader != null)
          BorderContainer(
            child: subBannerHeader,
          ),
        BorderContainer(
          child: AppInfos(
            strict: appData.strict,
            confinementName: appData.confinementName,
            license: appData.license,
            installDate: appData.installDate,
            installDateIsoNorm: appData.installDateIsoNorm,
            version: appData.version,
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
        title: Text(appData.title),
        leading: InkWell(
          onTap: onPop,
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
