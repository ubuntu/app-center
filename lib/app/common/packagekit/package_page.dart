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
import 'package:software/app/common/app_page/app_loading_page.dart';
import 'package:software/app/common/app_page/app_page.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/packagekit/package_controls.dart';
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/app/common/utils.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/appstream/appstream_utils.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({
    super.key,
    this.appstream,
    this.snap,
  });

  final AppstreamComponent? appstream;
  final Snap? snap;

  static Widget create({
    String? path,
    required BuildContext context,
    PackageKitPackageId? packageId,
    AppstreamComponent? appstream,
    Snap? snap,
  }) {
    return ChangeNotifierProvider(
      create: (context) => PackageModel(
        path: path,
        service: getService<PackageService>(),
        packageId: packageId,
        appstream: appstream,
      ),
      child: PackagePage(
        appstream: appstream,
        snap: snap,
      ),
    );
  }

  static Future<void> push(
    BuildContext context, {
    PackageKitPackageId? id,
    AppstreamComponent? appstream,
    Snap? snap,
    bool replace = false,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PackageModel>().init().then((value) => initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();

    final appData = AppData(
      releasedAt: '',
      appSize: formatBytes(model.size, 2),
      confinementName: context.l10n.classic,
      license: model.license,
      strict: false,
      verified: false,
      starredDeveloper: false,
      website: model.url,
      summary: model.summary,
      title: model.title,
      name: model.packageId?.name ?? '',
      version: model.packageId?.version ?? '',
      screenShotUrls: model.screenshotUrls,
      description: model.description,
      userReviews: model.userReviews,
      averageRating: model.averageRating,
      appFormat: AppFormat.packageKit,
      versionChanged: model.versionChanged,
    );
    var packageControls = PackageControls(
      isInstalled: model.isInstalled,
      versionChanged: model.versionChanged,
      packageState: model.packageState,
      remove: () => model.remove(),
      install: model.install,
      hasDependencies: model.uninstalledDependencyNames.isNotEmpty,
      showDeps: () => showDialog(
        context: context,
        builder: (context) => _ShowDepsDialog(
          packageName: model.title,
          onInstall: model.install,
          dependencies: model.uninstalledDependencyNames,
        ),
      ),
    );

    final dependencies = BorderContainer(
      child: YaruExpandable(
        header: Text(
          context.l10n.dependencies,
          style: Theme.of(context).textTheme.headline6,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: model.uninstalledDependencyNames
                .map(
                  (e) => ListTile(
                    title: Text(e),
                    leading: const Icon(YaruIcons.package_deb),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    return !initialized
        ? const AppLoadingPage()
        : AppPage(
            onFileSelect: model.path == null
                ? null
                : (path) async {
                    initialized = false;
                    model.path = path;
                    model.packageId = null;

                    await model.init().then((_) => initialized = true);
                  },
            appData: appData,
            permissionContainer: null,
            icon: AppIcon(
              iconUrl: model.iconUrl,
              size: 150,
            ),
            controls: widget.snap == null
                ? packageControls
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
                        );
                      }
                    },
                  ),
            subControlPageHeader: widget.snap != null ? packageControls : null,
            subDescription:
                model.uninstalledDependencyNames.isEmpty ? null : dependencies,
            onReviewSend: model.sendReview,
            onRatingUpdate: (v) => model.reviewRating = v,
            onReviewTitleChanged: (v) => model.reviewTitle = v,
            onReviewUserChanged: (v) => model.reviewUser = v,
            onReviewChanged: (v) => model.review = v,
            reviewRating: model.reviewRating,
            review: model.review,
            reviewTitle: model.reviewTitle,
            reviewUser: model.reviewUser,
          );
  }
}

class _ShowDepsDialog extends StatefulWidget {
  final void Function() onInstall;
  final String packageName;
  final List<String> dependencies;

  const _ShowDepsDialog({
    required this.onInstall,
    required this.dependencies,
    required this.packageName,
  });

  @override
  State<_ShowDepsDialog> createState() => _ShowDepsDialogState();
}

class _ShowDepsDialogState extends State<_ShowDepsDialog> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: SizedBox(
        width: 500,
        child: YaruTitleBar(
          title: Text(context.l10n.dependencies),
        ),
      ),
      titlePadding: EdgeInsets.zero,
      scrollable: true,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kYaruPagePadding / 2),
            child: Text(
              context.l10n.dependenciesListing(
                widget.dependencies.length,
                widget.packageName,
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kYaruPagePadding),
            child: Text(
              context.l10n.dependenciesQuestion,
              style: theme.textTheme.bodyLarge!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          YaruExpandable(
            onChange: (isExpanded) => setState(() => _isExpanded = isExpanded),
            header: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                _isExpanded
                    ? context.l10n.dependencies
                    : context.l10n.dependenciesFullList,
                style: TextStyle(
                  color: _isExpanded ? null : theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: Column(
              children: [
                for (var d in widget.dependencies)
                  ListTile(
                    title: Text(d),
                    leading: const Icon(
                      YaruIcons.package_deb,
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: widget.onInstall,
          child: Text(context.l10n.install),
        )
      ],
    );
  }
}
