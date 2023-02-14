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
import 'package:snapd/snapd.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/app_page/app_format_toggle_buttons.dart';
import 'package:software/app/common/app_page/app_page.dart';
import 'package:software/app/common/app_rating.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/app/common/rating_model.dart';
import 'package:software/app/common/review_model.dart';
import 'package:software/app/common/snap/snap_channel_button.dart';
import 'package:software/app/common/snap/snap_connections_button.dart';
import 'package:software/app/common/snap/snap_connections_dialog.dart';
import 'package:software/app/common/snap/snap_controls.dart';
import 'package:software/app/common/snap/snap_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/odrs_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapPage extends StatefulWidget {
  const SnapPage({super.key, this.appstream, required this.snap});

  /// Optional AppstreamComponent if found
  final AppstreamComponent? appstream;
  final Snap snap;

  static Widget create({
    required BuildContext context,
    required Snap snap,
    PackageKitPackageId? packageId,
    AppstreamComponent? appstream,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SnapModel>(
            create: (_) => SnapModel(
              doneMessage: context.l10n.done,
              getService<SnapService>(),
              huskSnapName: snap.name,
            ),
          ),
          ChangeNotifierProvider<ReviewModel>(
            create: (_) => ReviewModel(getService<OdrsService>()),
          ),
        ],
        child: SnapPage(
          appstream: appstream,
          snap: snap,
        ),
      );

  static Future<void> push({
    required BuildContext context,
    required Snap snap,
    AppstreamComponent? appstream,
    bool replace = false,
  }) {
    final route = MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return SnapPage.create(
          context: context,
          snap: snap,
          appstream: appstream,
        );
      },
    );
    return replace
        ? Navigator.pushReplacement(context, route)
        : Navigator.push(
            context,
            route,
          );
  }

  @override
  State<SnapPage> createState() => _SnapPageState();
}

class _SnapPageState extends State<SnapPage> {
  bool initialized = false;

  String get _ratingId => widget.snap.ratingId;
  String get _ratingVersion => widget.snap.version;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SnapModel>().init().then((value) => initialized = true);
      context.read<ReviewModel>().load(_ratingId, _ratingVersion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    final rating = context.select((RatingModel m) => m.getRating(_ratingId));
    final userReviews = context.select((ReviewModel m) => m.userReviews);
    final theme = Theme.of(context);

    final appData = AppData(
      releasedAt: model.selectedChannelReleasedAt,
      appSize: model.downloadSize,
      confinementName: model.confinement != null ? model.confinement!.name : '',
      installDate: model.installDate,
      installDateIsoNorm: model.installDateIsoNorm,
      license: model.license ?? '',
      strict: model.strict,
      verified: model.verified,
      starredDeveloper: model.starredDeveloper,
      publisherName: model.publisher?.displayName ?? '',
      website: model.storeUrl ?? '',
      summary: model.summary ?? '',
      title: model.title ?? '',
      name: model.name ?? '',
      version: model.selectableChannels[model.channelToBeInstalled]?.version ??
          model.version,
      screenShotUrls: model.screenshotUrls ?? [],
      description: model.description ?? '',
      versionChanged: model.isUpdateAvailable(),
      userReviews: userReviews ?? [],
      averageRating: rating?.average ?? 0.0,
      appFormat: AppFormat.snap,
      contact: model.contact ?? context.l10n.unknown,
    );

    final controls = SnapControls(
      appstream: widget.appstream,
    );

    const snapLabel = SizedBox(
      height: 39,
      child: AppFormatLabel(appFormat: AppFormat.snap),
    );

    final snapLabelContainerCut = YaruBorderContainer(
      color: theme.dividerColor,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(kYaruButtonRadius),
        bottomLeft: Radius.circular(kYaruButtonRadius),
      ),
      child: snapLabel,
    );

    final snapLabelWithChannelButton = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        snapLabelContainerCut,
        OutlinedButtonTheme(
          data: OutlinedButtonThemeData(
            style: OutlinedButtonTheme.of(context).style?.copyWith(
                  shape: MaterialStateProperty.resolveWith(
                    (states) => const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(kYaruButtonRadius),
                        bottomRight: Radius.circular(kYaruButtonRadius),
                      ),
                    ),
                  ),
                ),
          ),
          child: const SnapChannelPopupButton(),
        )
      ],
    );

    final preControls = Wrap(
      spacing: 10,
      children: [
        if (widget.appstream != null)
          AppFormatToggleButtons(
            isSelected: const [
              true,
              false,
            ],
            onPressed: (v) {
              if (v == 1) {
                PackagePage.push(
                  context,
                  appstream: widget.appstream,
                  snap: widget.snap,
                  replace: true,
                );
              }
            },
          )
        else
          snapLabelWithChannelButton,
        if (model.snapIsInstalled && model.strict)
          SnapConnectionsButton(
            onPressed: () => showDialog(
              context: context,
              builder: ((context) => ChangeNotifierProvider.value(
                    value: model,
                    child: const SnapConnectionsDialog(),
                  )),
            ),
          )
      ],
    );

    final review = context.read<ReviewModel>();
    return AppPage(
      initialized: initialized,
      appData: appData,
      appIsInstalled: model.snapIsInstalled,
      controls: controls,
      preControls: preControls,
      icon: AppIcon(
        iconUrl: model.iconUrl,
        size: 150,
      ),
      onReviewSend: () => review.submit(_ratingId, _ratingVersion),
      onRatingUpdate: (v) => review.rating = v,
      onReviewTitleChanged: (v) => review.title = v,
      onReviewUserChanged: (v) => review.user = v,
      onReviewChanged: (v) => review.review = v,
      reviewRating: review.rating,
      review: review.review,
      reviewTitle: review.title,
      reviewUser: review.user,
      onVote: review.vote,
      onFlag: review.flag,
    );
  }
}
