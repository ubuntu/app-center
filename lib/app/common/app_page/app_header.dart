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
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/publisher_name.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import 'package:software/l10n/l10n.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
const iconSize = 108.0;

class BannerAppHeader extends StatelessWidget {
  const BannerAppHeader({
    super.key,
    required this.appData,
    required this.controls,
    required this.icon,
    required this.windowSize,
    this.subControls,
    this.onShare,
    this.onPublisherSearch,
  });

  final AppData appData;
  final Widget controls;
  final Widget? subControls;

  final Widget icon;
  final Size windowSize;
  final Function()? onShare;
  final void Function()? onPublisherSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 170,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: iconSize,
                width: iconSize,
                child: FittedBox(
                  child: icon,
                ),
              ),
              const SizedBox(width: kYaruPagePadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appData.title,
                      style: theme.textTheme.titleLarge!.copyWith(fontSize: 23),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    PublisherName(
                      onPublisherSearch: onPublisherSearch,
                      height: 14,
                      publisherName: appData.publisherName,
                      website: appData.website,
                      verified: appData.verified,
                      starDev: appData.starredDeveloper,
                      limitChildWidth: false,
                      enhanceChildText: true,
                    ),
                    const SizedBox(
                      height: kYaruPagePadding,
                    ),
                    controls,
                    if (subControls != null)
                      Padding(
                        padding: const EdgeInsets.only(top: kYaruPagePadding),
                        child: subControls!,
                      ),
                  ],
                ),
              ),
              if (onShare != null)
                YaruIconButton(
                  tooltip: context.l10n.share,
                  icon: const Icon(YaruIcons.share),
                  onPressed: onShare,
                )
            ],
          ),
        ],
      ),
    );
  }
}

class PageAppHeader extends StatelessWidget {
  const PageAppHeader({
    super.key,
    required this.appData,
    required this.controls,
    required this.icon,
    this.subControls,
    this.onShare,
    this.onPublisherSearch,
  });

  final AppData appData;
  final Widget controls;
  final Widget icon;
  final Widget? subControls;
  final Function()? onShare;
  final void Function()? onPublisherSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            SizedBox(
              height: iconSize,
              width: iconSize,
              child: FittedBox(
                child: icon,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kYaruPagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    appData.title,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Center(
                    child: PublisherName(
                      onPublisherSearch: onPublisherSearch,
                      height: 14,
                      publisherName: appData.publisherName,
                      website: appData.website,
                      verified: appData.verified,
                      starDev: appData.starredDeveloper,
                      limitChildWidth: false,
                      enhanceChildText: true,
                    ),
                  ),
                ],
              ),
            ),
            if (onShare != null)
              YaruIconButton(
                tooltip: context.l10n.share,
                icon: const Icon(YaruIcons.share),
                onPressed: onShare,
              )
          ],
        ),
        controls,
        if (subControls != null) subControls!,
        Text(
          appData.summary,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
