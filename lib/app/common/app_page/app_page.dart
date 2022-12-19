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

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_page/app_description.dart';
import 'package:software/app/common/app_page/app_header.dart';
import 'package:software/app/common/app_page/app_infos.dart';
import 'package:software/app/common/app_page/app_reviews.dart';
import 'package:software/app/common/app_page/media_tile.dart';
import 'package:software/app/common/app_page/page_layouts.dart';
import 'package:software/app/common/app_page/app_swipe_gesture.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/safe_network_image.dart';
import 'package:software/l10n/l10n.dart';
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
    this.appIsInstalled = false,
    this.onRatingUpdate,
    this.onReviewSend,
    this.onReviewChanged,
    this.onReviewTitleChanged,
    this.onReviewUserChanged,
    this.review,
    this.reviewTitle,
    this.reviewUser,
    this.reviewRating,
    this.onVote,
    this.onFlag,
    this.onFileSelect,
    this.onAppStreamSelect,
    this.onSnapSelect,
  });

  final AppData appData;
  final Widget icon;
  final Widget? permissionContainer;
  final Widget controls;
  final Widget? subControlPageHeader;
  final Widget? subBannerHeader;
  final bool appIsInstalled;

  final double? reviewRating;
  final String? review;
  final String? reviewTitle;
  final String? reviewUser;
  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final void Function(String)? onReviewChanged;
  final void Function(String)? onReviewTitleChanged;
  final void Function(String)? onReviewUserChanged;
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;
  final void Function(String path)? onFileSelect;
  final void Function()? onSnapSelect;
  final void Function()? onAppStreamSelect;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late YaruCarouselController controller;

  @override
  void initState() {
    super.initState();
    controller = YaruCarouselController(
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
    final theme = Theme.of(context);
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final windowHeight = windowSize.height;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1200;
    final isWindowWide = windowWidth > 1200;

    final icon = Stack(
      alignment: Alignment.bottomRight,
      children: [
        widget.icon,
        PopupMenuButton<AppFormat>(
          initialValue: widget.appData.appFormat,
          tooltip: context.l10n.appFormat,
          itemBuilder: (context) => [
            PopupMenuItem<AppFormat>(
              enabled: widget.onSnapSelect != null,
              onTap: widget.onSnapSelect,
              child: const Text('Snap'),
            ),
            PopupMenuItem<AppFormat>(
              enabled: widget.onAppStreamSelect != null,
              onTap: widget.onAppStreamSelect,
              child: const Text('Debian'),
            )
          ],
          child: YaruBorderContainer(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(40),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.appData.appFormat == AppFormat.snap
                  ? const Icon(YaruIcons.snapcraft)
                  : const Icon(YaruIcons.debian),
            ),
          ),
        )
      ],
    );

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
      reviewRating: widget.reviewRating,
      review: widget.review,
      reviewTitle: widget.reviewTitle,
      reviewUser: widget.reviewUser,
      averageRating: widget.appData.averageRating,
      userReviews: widget.appData.userReviews,
      appIsInstalled: widget.appIsInstalled,
      onRatingUpdate: widget.onRatingUpdate,
      onReviewSend: widget.onReviewSend,
      onReviewChanged: widget.onReviewChanged,
      onReviewTitleChanged: widget.onReviewTitleChanged,
      onReviewUserChanged: widget.onReviewUserChanged,
      onVote: widget.onVote,
      onFlag: widget.onFlag,
    );

    final normalWindowAppHeader = BorderContainer(
      child: BannerAppHeader(
        appData: widget.appData,
        controls: widget.controls,
        icon: icon,
      ),
    );

    final wideWindowAppHeader = BorderContainer(
      width: 500,
      child: PageAppHeader(
        appData: widget.appData,
        icon: icon,
        controls: widget.controls,
        subControls: widget.subControlPageHeader,
      ),
    );

    final narrowWindowAppHeader = BorderContainer(
      height: 700,
      child: PageAppHeader(
        appData: widget.appData,
        icon: icon,
        controls: widget.controls,
        subControls: widget.subControlPageHeader,
      ),
    );

    final normalWindowLayout = OnePageLayout(
      windowSize: windowSize,
      adaptivePadding: true,
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
        ratingsAndReviews,
        if (widget.permissionContainer != null) widget.permissionContainer!,
      ],
    );

    final wideWindowLayout = PanedPageLayout(
      leftChild: wideWindowAppHeader,
      rightChildren: [
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        ratingsAndReviews,
        if (widget.permissionContainer != null) widget.permissionContainer!,
      ],
      windowSize: windowSize,
    );

    final narrowWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        narrowWindowAppHeader,
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        ratingsAndReviews,
        if (widget.permissionContainer != null) widget.permissionContainer!,
      ],
    );

    final body = isWindowWide
        ? wideWindowLayout
        : isWindowNormalSized
            ? normalWindowLayout
            : narrowWindowLayout;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appData.title),
        titleSpacing: 0,
        leading: widget.onFileSelect != null
            ? Center(
                child: IconButton(
                  style: IconButton.styleFrom(fixedSize: const Size(40, 40)),
                  onPressed: () async {
                    final path = await openFile(
                      acceptedTypeGroups: [
                        XTypeGroup(
                          label: context.l10n.debianPackages,
                          extensions: const <String>[
                            'deb',
                          ],
                        )
                      ],
                    );
                    if (null != path && widget.onFileSelect != null) {
                      widget.onFileSelect!(path.path);
                    }
                  },
                  icon: const Icon(YaruIcons.document_open),
                ),
              )
            : _CustomBackButton(
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: BackGesture(
        child: body,
      ),
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
        title: const YaruCloseButton(
          alignment: Alignment.centerRight,
        ),
        contentPadding: const EdgeInsets.only(bottom: 20),
        titlePadding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
        children: [
          SizedBox(
            height: widget.windowHeight - 150,
            child: YaruCarousel(
              controller: controller,
              nextIcon: const Icon(YaruIcons.go_next),
              previousIcon: const Icon(YaruIcons.go_previous),
              navigationControls: widget.appData.screenShotUrls.length > 1,
              width: widget.windowWidth,
              placeIndicatorMarginTop: 20.0,
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
