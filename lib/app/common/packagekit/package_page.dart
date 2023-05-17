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
import 'package:collection/collection.dart';
import 'package:data_size/data_size.dart';
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
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/packagekit/dependency_dialogs.dart';
import 'package:software/app/common/packagekit/package_controls.dart';
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/app/common/rating_model.dart';
import 'package:software/app/common/review_model.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/appstream/appstream_utils.dart';
import 'package:software/services/odrs_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import '../expandable_title.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({
    super.key,
    this.appstream,
    this.snap,
    this.enableSearch = true,
  });

  final AppstreamComponent? appstream;
  final Snap? snap;
  final bool enableSearch;

  static Widget create({
    String? path,
    required BuildContext context,
    PackageKitPackageId? packageId,
    AppstreamComponent? appstream,
    Snap? snap,
    bool enableSearch = true,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PackageModel(
            path: path,
            service: getService<PackageService>(),
            packageId: packageId,
            appstream: appstream,
          ),
        ),
        ChangeNotifierProvider<ReviewModel>(
          create: (_) => ReviewModel(getService<OdrsService>()),
        ),
      ],
      child: PackagePage(
        appstream: appstream,
        snap: snap,
        enableSearch: enableSearch,
      ),
    );
  }

  static Future<void> push(
    BuildContext context, {
    PackageKitPackageId? id,
    AppstreamComponent? appstream,
    Snap? snap,
    bool replace = false,
    bool enableSearch = true,
  }) {
    assert(id != null || appstream != null);
    return (id == null ? appstream!.packageKitId : Future.value(id)).then(
      (id) => replace
          ? Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return PackagePage.create(
                    context: context,
                    packageId: id,
                    appstream: appstream,
                    snap: snap,
                    enableSearch: enableSearch,
                  );
                },
              ),
            )
          : Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return PackagePage.create(
                    context: context,
                    packageId: id,
                    appstream: appstream,
                    snap: snap,
                    enableSearch: enableSearch,
                  );
                },
              ),
            ),
    );
  }

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  bool initialized = false;

  String get _ratingId => widget.appstream?.ratingId ?? 'unknown';
  String get _ratingVersion =>
      context.read<PackageModel>().packageId?.version ?? 'unknown';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<PackageModel>()
          .init()
          .then((_) => setState(() => initialized = true));
      context.read<ReviewModel>().load(_ratingId, _ratingVersion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    final theme = Theme.of(context);
    final rating = context.select((RatingModel m) => m.getRating(_ratingId));
    final userReviews = context.select((ReviewModel m) => m.userReviews);

    final appData = AppData(
      publisherName: model.getDeveloperName(context) ?? context.l10n.unknown,
      publisherUsername:
          model.getDeveloperName(context) ?? context.l10n.unknown,
      releasedAt: model.releasedAt ?? context.l10n.unknown,
      appSize: model.getFormattedSize() ?? context.l10n.unknown,
      confinementName: context.l10n.classic,
      license: model.license ?? context.l10n.unknown,
      strict: false,
      verified: false,
      starredDeveloper: false,
      website: model.url ?? context.l10n.unknown,
      summary: model.summary ?? context.l10n.unknown,
      title: model.title ?? context.l10n.unknown,
      name: model.packageId?.name ?? '',
      version: model.packageId?.version ?? '',
      screenShotUrls: model.screenshotUrls,
      description: model.description,
      userReviews: userReviews ?? [],
      appRating: rating,
      appFormat: AppFormat.packageKit,
      versionChanged: model.versionChanged ?? false,
      contact: context.l10n.unknown,
      installDate: context.l10n.unknown,
      installDateIsoNorm: context.l10n.unknown,
    );

    final preControls = widget.snap == null
        ? BorderContainer(
            color: theme.dividerColor,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            borderRadius: 6,
            child: const SizedBox(
              height: 40,
              child: AppFormatLabel(
                appFormat: AppFormat.packageKit,
                isSelected: true,
              ),
            ),
          )
        : AppFormatToggleButtons(
            isSelected: const [
              false,
              true,
            ],
            onPressed: (v) {
              if (v == 0) {
                SnapPage.push(
                  context: context,
                  appstream: widget.appstream,
                  snap: widget.snap!,
                  replace: true,
                  enableSearch: widget.enableSearch,
                );
              }
            },
          );

    var controls = PackageControls(
      showInstallDeps: () => showDialog(
        context: context,
        builder: (context) => InstallDepsDialog(
          packageName: model.title ?? context.l10n.unknown,
          onInstall: model.install,
          dependencies: model.dependencies,
        ),
      ),
      showRemoveDeps: () => showDialog(
        context: context,
        builder: (context) => RemoveDepsDialog(
          packageName: model.title ?? context.l10n.unknown,
          onRemove: (autoremove) => model.remove(autoremove: autoremove),
          dependencies: model.dependencies,
        ),
      ),
    );

    final dependencies = BorderContainer(
      initialized: initialized,
      child: YaruExpandable(
        header: ExpandableContainerTitle(
          '${context.l10n.dependencies} (${model.dependencies.length}) - '
          '${model.dependencies.map((d) => d.size).sum.formatByteSize()}',
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: model.dependencies
                .map<Widget>(
                  (e) => ListTile(
                    title: Text(e.id.name),
                    subtitle: e.summary != null
                        ? Text(
                            e.summary!,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          )
                        : null,
                    leading: Icon(
                      YaruIcons.package_deb,
                      color: theme.colorScheme.onSurface,
                    ),
                    trailing: Text(
                      e.size.formatByteSize(),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    final review = context.read<ReviewModel>();
    return AppPage(
      enableSearch: widget.enableSearch,
      initialized: initialized,
      appData: appData,
      appIsInstalled: model.isInstalled ?? false,
      icon: AppIcon(
        iconUrl: model.iconUrl,
        size: 150,
      ),
      preControls: preControls,
      controls: controls,
      subDescription: model.dependencies.isEmpty ? null : dependencies,
      onReviewSend: () => review.submit(_ratingId, _ratingVersion),
      onRatingUpdate: (v) => review.rating = v,
      onReviewTitleChanged: (v) => review.title = v,
      onReviewUserChanged: (v) => review.user = v,
      onReviewChanged: (v) => review.review = v,
      reviewRating: review.rating,
      review: review.review,
      reviewTitle: review.title,
      reviewUser: review.user,
    );
  }
}
