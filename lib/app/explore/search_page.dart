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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:software/services/appstream/appstream_utils.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/loading_banner_grid.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    return FutureBuilder<Map<String, AppFinding>>(
      future: model.search(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingBannerGrid();
        }

        return snapshot.hasData && snapshot.data!.isNotEmpty
            ? GridView.builder(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                gridDelegate: kGridDelegate,
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final appFinding = snapshot.data!.entries.elementAt(index);
                  var showSnap = model.appFormats.contains(AppFormat.snap);
                  var showPackageKit =
                      model.appFormats.contains(AppFormat.packageKit);
                  return SearchSnapBanner(
                    appFinding: appFinding,
                    showSnap: showSnap,
                    showPackageKit: showPackageKit,
                  );
                },
              )
            : _NoSearchResultPage(message: context.l10n.noPackageFound);
      },
    );
  }
}

class SearchSnapBanner extends StatelessWidget {
  const SearchSnapBanner({
    Key? key,
    required this.appFinding,
    required this.showSnap,
    required this.showPackageKit,
  }) : super(key: key);

  final MapEntry<String, AppFinding> appFinding;
  final bool showSnap;
  final bool showPackageKit;

  @override
  Widget build(BuildContext context) {
    var onTap = appFinding.value.snap != null &&
            appFinding.value.appstream != null &&
            showSnap &&
            showPackageKit
        ? () => showDialog(
              useRootNavigator: false,
              context: context,
              builder: (context) => _AppFormatSelectDialog(
                title: appFinding.value.snap!.name,
                onPackageSelect: () => PackagePage.push(
                  context,
                  appstream: appFinding.value.appstream!,
                ),
                onSnapSelect: () => SnapPage.push(
                  context,
                  appFinding.value.snap!,
                ),
              ),
            )
        : () {
            if (appFinding.value.appstream != null && showPackageKit) {
              PackagePage.push(
                context,
                appstream: appFinding.value.appstream!,
              );
            }
            if (appFinding.value.snap != null && showSnap) {
              SnapPage.push(context, appFinding.value.snap!);
            }
          };
    var iconUrl =
        appFinding.value.snap?.iconUrl ?? appFinding.value.appstream?.icon;
    var title = appFinding.key;

    var subtitle = _SearchBannerSubtitle(
      appFinding: appFinding.value,
      showSnap: showSnap,
      showPackageKit: showPackageKit,
    );

    var appIcon = Padding(
      padding: const EdgeInsets.only(bottom: 25, right: 5),
      child: AppIcon(
        iconUrl: iconUrl,
      ),
    );

    return YaruBanner.tile(
      padding: const EdgeInsets.only(
        left: kYaruPagePadding,
        right: kYaruPagePadding,
      ),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle,
      icon: appIcon,
      onTap: onTap,
    );
  }
}

class _NoSearchResultPage extends StatelessWidget {
  const _NoSearchResultPage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🐣❓',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Text(
              message,
              style: theme.textTheme.headline4?.copyWith(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }
}

class _SearchBannerSubtitle extends StatelessWidget {
  const _SearchBannerSubtitle({
    Key? key,
    required this.appFinding,
    this.showSnap = true,
    this.showPackageKit = true,
  }) : super(key: key);

  final AppFinding appFinding;
  final bool showSnap, showPackageKit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appFinding.snap?.summary ??
              appFinding.appstream?.localizedSummary() ??
              '',
          overflow: TextOverflow.ellipsis,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RatingBar.builder(
                initialRating: appFinding.rating ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.zero,
                itemSize: 20,
                itemBuilder: (context, _) => Icon(
                  YaruIcons.star_filled,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                onRatingUpdate: (rating) {},
                ignoreGestures: true,
              ),
              _PackageIndicator(
                appFinding: appFinding,
                showSnap: showSnap,
                showPackageKit: showPackageKit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageIndicator extends StatelessWidget {
  const _PackageIndicator({
    // ignore: unused_element
    super.key,
    required this.appFinding,
    this.showSnap = true,
    this.showPackageKit = true,
  });

  final AppFinding appFinding;
  final bool showSnap;
  final bool showPackageKit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appFormatEmblemColor = theme.disabledColor;
    return Row(
      children: [
        if (appFinding.snap != null && showSnap)
          Icon(
            YaruIcons.snapcraft,
            color: appFormatEmblemColor,
            size: 20,
          ),
        if (appFinding.appstream != null && showPackageKit)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Icon(
              YaruIcons.debian,
              color: appFormatEmblemColor,
              size: 20,
            ),
          )
      ],
    );
  }
}

class _AppFormatSelectDialog extends StatelessWidget {
  // ignore: unused_element
  const _AppFormatSelectDialog({
    // ignore: unused_element
    super.key,
    required this.title,
    required this.onSnapSelect,
    required this.onPackageSelect,
  });

  final String title;
  final Function() onSnapSelect;
  final Function() onPackageSelect;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: YaruTitleBar(title: Text(title)),
      titlePadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.only(
        left: kYaruPagePadding,
        right: kYaruPagePadding,
        bottom: kYaruPagePadding,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      content: Text(context.l10n.multiAppFormatsFound),
      actions: [
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: OutlinedButton(
                    onPressed: onPackageSelect,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(YaruIcons.debian, size: 25),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppFormat.packageKit.localize(context.l10n),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: kYaruPagePadding,
              ),
              Expanded(
                child: SizedBox(
                  height: 90,
                  child: OutlinedButton(
                    onPressed: onSnapSelect,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          YaruIcons.snapcraft,
                          size: 25,
                        ),
                        const SizedBox(
                          height: kYaruPagePadding,
                        ),
                        Text(
                          AppFormat.snap.localize(context.l10n),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
