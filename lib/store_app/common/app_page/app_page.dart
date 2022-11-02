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
import 'package:flutter/services.dart';
import 'package:software/store_app/common/app_data.dart';
import 'package:software/store_app/common/app_page/app_description.dart';
import 'package:software/store_app/common/app_page/app_header.dart';
import 'package:software/store_app/common/app_page/app_infos.dart';
import 'package:software/store_app/common/app_page/app_reviews.dart';
import 'package:software/store_app/common/app_page/media_tile.dart';
import 'package:software/store_app/common/app_page/page_layouts.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/safe_network_image.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppPage extends StatefulWidget {
  const AppPage({
    super.key,
    required this.appData,
    required this.icon,
    required this.permissionContainer,
    required this.controls,
    this.subControlPageHeader,
    this.subBannerHeader,
  });

  final AppData appData;
  final Widget icon;
  final Widget? permissionContainer;
  final Widget controls;
  final Widget? subControlPageHeader;
  final Widget? subBannerHeader;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late YaruCarouselController controller;

  @override
  void initState() {
    super.initState();
    controller = YaruCarouselController(
      pagesLength: widget.appData.screenShotUrls.length,
      viewportFraction: 1,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final windowHeight = windowSize.height;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1200;
    final isWindowWide = windowWidth > 1200;

    final media = BorderContainer(
      child: YaruCarousel(
        controller: controller,
        nextIcon: const Icon(YaruIcons.go_next),
        previousIcon: const Icon(YaruIcons.go_previous),
        navigationControls: widget.appData.screenShotUrls.length > 1,
        height: 400,
        children: [
          for (int i = 0; i < widget.appData.screenShotUrls.length; i++)
            MediaTile(
              url: widget.appData.screenShotUrls[i],
              onTap: () => showDialog(
                context: context,
                builder: (c) => _CarouselDialog(
                  windowHeight: windowHeight,
                  appData: widget.appData,
                  windowWidth: windowWidth,
                  initialIndex: i,
                ),
              ),
            )
        ],
      ),
    );

    final description = BorderContainer(
      child: AppDescription(description: widget.appData.description),
    );

    final ratingsAndReviews = AppReviews(
      rating: widget.appData.rating,
      userReviews: widget.appData.userReviews,
    );

    final normalWindowAppHeader = BorderContainer(
      child: BannerAppHeader(
        appData: widget.appData,
        controls: widget.controls,
        icon: widget.icon,
      ),
    );

    final wideWindowAppHeader = BorderContainer(
      width: 500,
      child: PageAppHeader(
        appData: widget.appData,
        icon: widget.icon,
        controls: widget.controls,
        subControls: widget.subControlPageHeader,
      ),
    );

    final narrowWindowAppHeader = BorderContainer(
      height: 700,
      child: PageAppHeader(
        appData: widget.appData,
        icon: widget.icon,
        controls: widget.controls,
        subControls: widget.subControlPageHeader,
      ),
    );

    final normalWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        normalWindowAppHeader,
        if (widget.subBannerHeader != null)
          BorderContainer(
            child: widget.subBannerHeader,
          ),
        BorderContainer(
          child: AppInfos(
            strict: widget.appData.strict,
            confinementName: widget.appData.confinementName,
            license: widget.appData.license,
            installDate: widget.appData.installDate,
            installDateIsoNorm: widget.appData.installDateIsoNorm,
            version: widget.appData.version,
            versionChanged: widget.appData.versionChanged,
          ),
        ),
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        if (widget.permissionContainer != null) widget.permissionContainer!,
        ratingsAndReviews
      ],
    );

    final wideWindowLayout = PanedPageLayout(
      leftChild: wideWindowAppHeader,
      rightChildren: [
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        if (widget.permissionContainer != null) widget.permissionContainer!,
        ratingsAndReviews
      ],
      windowSize: windowSize,
    );

    final narrowWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        narrowWindowAppHeader,
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        if (widget.permissionContainer != null) widget.permissionContainer!,
        ratingsAndReviews
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appData.title),
        titleSpacing: 0,
        leading: _CustomBackButton(
          onPressed: () => Navigator.pop(context),
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

class _CarouselDialog extends StatefulWidget {
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
  State<_CarouselDialog> createState() => _CarouselDialogState();
}

class _CarouselDialogState extends State<_CarouselDialog> {
  late YaruCarouselController controller;

  @override
  void initState() {
    super.initState();
    controller = YaruCarouselController(
      pagesLength: widget.appData.screenShotUrls.length,
      initialPage: widget.initialIndex,
      viewportFraction: 0.8,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.arrowRight) {
          controller.nextPage();
        } else if (value.logicalKey == LogicalKeyboardKey.arrowLeft) {
          controller.previousPage();
        }
      },
      child: SimpleDialog(
        title: const YaruTitleBar(),
        contentPadding: const EdgeInsets.only(bottom: 20),
        titlePadding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: widget.windowHeight - 150,
            child: YaruCarousel(
              controller: controller,
              nextIcon: const Icon(YaruIcons.go_next),
              previousIcon: const Icon(YaruIcons.go_previous),
              navigationControls: widget.appData.screenShotUrls.length > 1,
              width: widget.windowWidth,
              children: [
                for (final url in widget.appData.screenShotUrls)
                  SafeNetworkImage(url: url)
              ],
            ),
          )
        ],
      ),
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
