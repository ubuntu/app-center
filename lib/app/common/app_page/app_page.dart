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
import 'package:provider/provider.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/app_description.dart';
import 'package:software/app/common/app_page/app_header.dart';
import 'package:software/app/common/app_page/app_infos/additional_information.dart';
import 'package:software/app/common/app_page/app_infos/app_infos.dart';
import 'package:software/app/common/app_page/app_reviews.dart';
import 'package:software/app/common/app_page/app_swipe_gesture.dart';
import 'package:software/app/common/app_page/media_tile.dart';
import 'package:software/app/common/app_page/page_layouts.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/custom_back_button.dart';
import 'package:software/app/common/link.dart';
import 'package:software/app/common/safe_network_image.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppPage extends StatefulWidget {
  const AppPage({
    super.key,
    required this.appData,
    required this.icon,
    required this.preControls,
    this.controls,
    this.subDescription,
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
    this.initialized = false,
  });

  final bool initialized;
  final AppData appData;
  final Widget icon;
  final Widget preControls;
  final Widget? controls;
  final Widget? subDescription;
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
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1200;
    final isWindowWide = windowWidth > 1200;

    final icon = widget.icon;

    final media = BorderContainer(
      initialized: widget.initialized,
      child: YaruExpandable(
        isExpanded: true,
        header: Text(
          context.l10n.gallery,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        child: YaruCarousel(
          controller: controller,
          nextIcon: const Icon(YaruIcons.go_next),
          previousIcon: const Icon(YaruIcons.go_previous),
          navigationControls: widget.appData.screenShotUrls.length > 1,
          height: 400,
          width: 550,
          children: [
            for (int i = 0; i < widget.appData.screenShotUrls.length; i++)
              MediaTile(
                url: widget.appData.screenShotUrls[i],
                onTap: () => showDialog(
                  context: context,
                  builder: (c) => _CarouselDialog(
                    appData: widget.appData,
                    initialIndex: i,
                  ),
                ),
              )
          ],
        ),
      ),
    );

    final description = BorderContainer(
      initialized: widget.initialized,
      child: AppDescription(description: widget.appData.description),
    );

    final ratingsAndReviews = AppReviews(
      initialized: widget.initialized,
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

    final appInfos = BorderContainer(
      initialized: widget.initialized,
      child: AppInfos(
        appData: widget.appData,
      ),
    );

    final additionalInformation = BorderContainer(
      initialized: widget.initialized,
      child: AdditionalInformation(
        appData: widget.appData,
      ),
    );

    void onShare(AppData appData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${context.l10n.copiedToClipboard}: '),
              Link(url: appData.website, linkText: appData.website)
            ],
          ),
        ),
      );
      Clipboard.setData(ClipboardData(text: appData.website));
    }

    final normalWindowAppHeader = BorderContainer(
      initialized: widget.initialized,
      child: BannerAppHeader(
        windowSize: windowSize,
        appData: widget.appData,
        controls: widget.preControls,
        subControls: widget.controls,
        icon: icon,
        onShare: () => onShare(widget.appData),
      ),
    );

    final wideWindowAppHeader = BorderContainer(
      initialized: widget.initialized,
      width: 500,
      child: PageAppHeader(
        appData: widget.appData,
        icon: icon,
        controls: widget.preControls,
        subControls: widget.controls,
        onShare: () => onShare(widget.appData),
      ),
    );

    final narrowWindowAppHeader = BorderContainer(
      initialized: widget.initialized,
      height: 700,
      child: PageAppHeader(
        appData: widget.appData,
        icon: icon,
        controls: widget.preControls,
        subControls: widget.controls,
        onShare: () => onShare(widget.appData),
      ),
    );

    final normalWindowLayout = OnePageLayout(
      windowSize: windowSize,
      adaptivePadding: true,
      children: [
        normalWindowAppHeader,
        appInfos,
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        if (widget.subDescription != null) widget.subDescription!,
        ratingsAndReviews,
        additionalInformation,
      ],
    );

    final wideWindowLayout = PanedPageLayout(
      leftChild: wideWindowAppHeader,
      rightChildren: [
        appInfos,
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        if (widget.subDescription != null) widget.subDescription!,
        ratingsAndReviews,
        additionalInformation,
      ],
      windowSize: windowSize,
    );

    final narrowWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        narrowWindowAppHeader,
        appInfos,
        if (widget.appData.screenShotUrls.isNotEmpty) media,
        description,
        if (widget.subDescription != null) widget.subDescription!,
        ratingsAndReviews,
        additionalInformation,
      ],
    );

    final body = isWindowWide
        ? wideWindowLayout
        : isWindowNormalSized
            ? normalWindowLayout
            : narrowWindowLayout;

    final setSearchQuery = context.read<ExploreModel>().setSearchQuery;
    final search = context.read<ExploreModel>().search;
    final searchQuery = context.select((ExploreModel m) => m.searchQuery);

    return Scaffold(
      appBar: YaruWindowTitleBar(
        title: SearchField(
          key: ObjectKey(searchQuery),
          searchQuery: searchQuery,
          onChanged: setSearchQuery,
          onSubmitted: (_) => Navigator.of(context).pop(search()),
        ),
        leading: const CustomBackButton(),
      ),
      body: BackGesture(
        child: body,
      ),
    );
  }
}

class _CarouselDialog extends StatefulWidget {
  const _CarouselDialog({
    required this.appData,
    required this.initialIndex,
  });

  final AppData appData;
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
    final size = MediaQuery.of(context).size;
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
        title: YaruDialogTitleBar(
          title: Text(widget.appData.name),
        ),
        contentPadding: const EdgeInsets.only(bottom: 20, top: 20),
        titlePadding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: size.height - 150,
            width: size.width,
            child: YaruCarousel(
              controller: controller,
              nextIcon: const Icon(YaruIcons.go_next),
              previousIcon: const Icon(YaruIcons.go_previous),
              navigationControls: widget.appData.screenShotUrls.length > 1,
              width: size.width,
              placeIndicatorMarginTop: 20.0,
              children: [
                for (final url in widget.appData.screenShotUrls)
                  SafeNetworkImage(
                    url: url,
                    fit: BoxFit.fitWidth,
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
