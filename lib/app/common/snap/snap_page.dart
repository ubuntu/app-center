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
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/app_page/app_loading_page.dart';
import 'package:software/app/common/app_page/app_page.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/snap/snap_connections_settings.dart';
import 'package:software/app/common/snap/snap_controls.dart';
import 'package:software/app/common/snap/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

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
      ChangeNotifierProvider<SnapModel>(
        create: (_) => SnapModel(
          doneMessage: context.l10n.done,
          getService<SnapService>(),
          huskSnapName: snap.name,
        ),
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

  @override
  void initState() {
    super.initState();
    context.read<SnapModel>().init().then((value) => initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    final appData = AppData(
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
      versionChanged:
          model.selectableChannels[model.channelToBeInstalled]?.version !=
              model.version,
      userReviews: model.userReviews,
      averageRating: model.averageRating,
      appFormat: AppFormat.snap,
    );

    return !initialized
        ? const AppLoadingPage()
        : AppPage(
            appData: appData,
            appIsInstalled: model.snapIsInstalled,
            permissionContainer: model.showPermissions
                ? const BorderContainer(
                    child: SnapConnectionsSettings(),
                  )
                : null,
            controls: SnapControls(
              appstream: widget.appstream,
            ),
            icon: AppIcon(
              iconUrl: model.iconUrl,
              size: 150,
            ),
            onReviewSend: model.sendReview,
            onRatingUpdate: (v) => model.reviewRating = v,
            onReviewTitleChanged: (v) => model.reviewTitle = v,
            onReviewUserChanged: (v) => model.reviewUser = v,
            onReviewChanged: (v) => model.review = v,
            reviewRating: model.reviewRating,
            review: model.review,
            reviewTitle: model.reviewTitle,
            reviewUser: model.reviewUser,
            onVote: model.voteReview,
            onFlag: model.flagReview,
            onAppStreamSelect: widget.appstream != null
                ? () => PackagePage.push(
                      context,
                      appstream: widget.appstream,
                      snap: widget.snap,
                      replace: true,
                    )
                : null,
          );
  }
}
