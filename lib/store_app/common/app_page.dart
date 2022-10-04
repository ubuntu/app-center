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
import 'package:software/store_app/common/safe_network_image.dart';
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
  final Widget? permissionContainer;
  final Widget controls;
  final Widget? subControlPageHeader;
  final Widget? subBannerHeader;

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final windowHeight = windowSize.height;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1800;
    final isWindowWide = windowWidth > 1800;

    final media = BorderContainer(
      child: YaruCarousel(
        nextIcon: const Icon(YaruIcons.go_next),
        previousIcon: const Icon(YaruIcons.go_previous),
        navigationControls: appData.screenShotUrls.length > 1,
        viewportFraction: 1,
        height: 400,
        children: [
          for (int i = 0; i < appData.screenShotUrls.length; i++)
            MediaTile(
              url: appData.screenShotUrls[i],
              onTap: () => showDialog(
                context: context,
                builder: (c) => _CarouselDialog(
                  windowHeight: windowHeight,
                  appData: appData,
                  windowWidth: windowWidth,
                  initialIndex: i,
                ),
              ),
            )
        ],
      ),
    );

    final description = BorderContainer(
      child: AppDescription(description: appData.description),
    );

    final normalWindowAppHeader = BorderContainer(
      child: BannerAppHeader(
        headerData: appData,
        controls: controls,
        icon: icon,
      ),
    );

    final wideWindowAppHeader = BorderContainer(
      width: 500,
      child: PageAppHeader(
        appData: appData,
        icon: icon,
        controls: controls,
        subControls: subControlPageHeader,
      ),
    );

    final narrowWindowAppHeader = BorderContainer(
      height: 700,
      child: PageAppHeader(
        appData: appData,
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
            versionChanged: appData.versionChanged,
          ),
        ),
        if (appData.screenShotUrls.isNotEmpty) media,
        description,
        if (permissionContainer != null) permissionContainer!
      ],
    );

    final wideWindowLayout = PanedPageLayout(
      leftChild: wideWindowAppHeader,
      rightChildren: [
        if (appData.screenShotUrls.isNotEmpty) media,
        description,
        if (permissionContainer != null) permissionContainer!
      ],
      windowSize: windowSize,
    );

    final narrowWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        narrowWindowAppHeader,
        if (appData.screenShotUrls.isNotEmpty) media,
        description,
        if (permissionContainer != null) permissionContainer!
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(appData.title),
        leading: _CustomBackButton(
          onPressed: onPop,
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

class _CarouselDialog extends StatelessWidget {
  const _CarouselDialog({
    Key? key,
    required this.windowHeight,
    required this.appData,
    required this.windowWidth,
    required this.initialIndex,
  }) : super(key: key);

  final double windowHeight;
  final AppData appData;
  final double windowWidth;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const YaruDialogTitle(
        closeIconData: YaruIcons.window_close,
      ),
      contentPadding: const EdgeInsets.only(bottom: 20),
      titlePadding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: windowHeight - 150,
          child: YaruCarousel(
            initialIndex: initialIndex,
            nextIcon: const Icon(YaruIcons.go_next),
            previousIcon: const Icon(YaruIcons.go_previous),
            navigationControls: appData.screenShotUrls.length > 1,
            viewportFraction: 0.8,
            width: windowWidth,
            children: [
              for (final url in appData.screenShotUrls)
                SafeNetworkImage(url: url)
            ],
          ),
        )
      ],
    );
  }
}

class _CustomBackButton extends StatelessWidget {
  const _CustomBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        style: IconButton.styleFrom(fixedSize: const Size(40, 40)),
        onPressed: () {
          Navigator.maybePop(context);
          if (onPressed != null) onPressed!();
        },
        icon: const Icon(YaruIcons.go_previous),
      ),
    );
  }
}
