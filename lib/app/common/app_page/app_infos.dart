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
import 'package:software/app/common/app_data.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/app/common/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class AppInfos extends StatelessWidget {
  const AppInfos({
    Key? key,
    required this.appData,
    this.alignment = Alignment.center,
    this.wrapAlignment = WrapAlignment.center,
    this.runAlignment = WrapAlignment.center,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  final AppData appData;

  final Axis direction;
  final AlignmentGeometry alignment;
  final WrapAlignment wrapAlignment;
  final WrapAlignment runAlignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Wrap(
        alignment: wrapAlignment,
        runAlignment: runAlignment,
        spacing: 50,
        runSpacing: 40,
        direction: direction,
        children: [
          _PublisherName(
            publisherName: appData.publisherName ?? '',
            verified: appData.verified,
            starDev: appData.starredDeveloper,
            website: appData.website,
          ),
          InfoColumn(
            header: context.l10n.rating,
            tooltipMessage: appData.averageRating.toString(),
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: _RatingBar(averageRating: appData.averageRating ?? 0),
              ),
            ),
          ),
          _Version(
            version: appData.version,
            versionChanged: appData.versionChanged,
          ),
          _Confinement(
            strict: appData.strict,
            confinementName: appData.confinementName,
          ),
          InfoColumn(
            header: context.l10n.releasedAt,
            tooltipMessage: context.l10n.releasedAt,
            child: Align(
              alignment: Alignment.center,
              child: Text(appData.releasedAt),
            ),
          ),
          InfoColumn(
            header: context.l10n.size,
            tooltipMessage: context.l10n.size,
            child: Align(
              alignment: Alignment.center,
              child: Text(appData.appSize),
            ),
          ),
          _License(headerStyle: headerStyle, license: appData.license),
          _InstallDate(
            installDateIsoNorm: appData.installDateIsoNorm ?? '',
            installDate: appData.installDate ?? '',
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    Key? key,
    required this.averageRating,
  }) : super(key: key);

  final double averageRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RatingBar.builder(
      initialRating: averageRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: EdgeInsets.zero,
      itemSize: 15,
      itemBuilder: (context, _) => const Icon(
        YaruIcons.star_filled,
        color: kStarColor,
        size: 2,
      ),
      unratedColor: theme.colorScheme.onSurface.withOpacity(0.2),
      onRatingUpdate: (rating) {},
      ignoreGestures: true,
    );
  }
}

class _InstallDate extends StatelessWidget {
  const _InstallDate({
    Key? key,
    required this.installDateIsoNorm,
    required this.installDate,
  }) : super(key: key);

  final String installDateIsoNorm;
  final String installDate;

  @override
  Widget build(BuildContext context) {
    return InfoColumn(
      header: context.l10n.installDate,
      tooltipMessage: installDateIsoNorm,
      childWidth: 120,
      child: Text(
        installDate.isNotEmpty ? installDate : context.l10n.notInstalled,
        maxLines: 1,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  const InfoColumn({
    Key? key,
    required this.header,
    required this.child,
    required this.tooltipMessage,
    this.childWidth,
  }) : super(key: key);

  final String header;
  final String tooltipMessage;
  final Widget child;
  final double? childWidth;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            header,
            overflow: TextOverflow.ellipsis,
            style: headerStyle,
          ),
          SizedBox(
            width: childWidth ?? 100,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({
    Key? key,
    required this.version,
    this.versionChanged,
  }) : super(key: key);

  final String version;
  final bool? versionChanged;

  @override
  Widget build(BuildContext context) {
    return InfoColumn(
      header: context.l10n.version,
      tooltipMessage: version,
      child: Text(
        version,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: headerStyle.copyWith(
          fontWeight: FontWeight.normal,
          color: versionChanged == true
              ? Theme.of(context).brightness == Brightness.light
                  ? kGreenLight
                  : kGreenDark
              : null,
        ),
      ),
    );
  }
}

class _License extends StatelessWidget {
  const _License({
    Key? key,
    required this.headerStyle,
    required this.license,
  }) : super(key: key);

  final TextStyle headerStyle;
  final String license;

  @override
  Widget build(BuildContext context) {
    return InfoColumn(
      header: context.l10n.license,
      tooltipMessage: license,
      child: Text(
        license,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _Confinement extends StatelessWidget {
  const _Confinement({
    Key? key,
    required this.strict,
    required this.confinementName,
  }) : super(key: key);

  final bool strict;
  final String confinementName;

  @override
  Widget build(BuildContext context) {
    return InfoColumn(
      header: context.l10n.confinement,
      tooltipMessage: confinementName,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            strict ? YaruIcons.shield : YaruIcons.warning,
            size: 18,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            confinementName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PublisherName extends StatelessWidget {
  const _PublisherName({
    Key? key,
    this.verified = false,
    required this.publisherName,
    this.starDev = false,
    required this.website,
  }) : super(key: key);

  final bool verified;
  final bool starDev;
  final String publisherName;
  final String website;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(website)),
      child: InfoColumn(
        header: context.l10n.publisher,
        tooltipMessage: website,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (verified)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.verified,
                    color: light ? kGreenLight : kGreenDark,
                    size: 14,
                  ),
                )
              else if (starDev)
                const Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: _StarDeveloper(),
                ),
              Expanded(
                child: Text(
                  publisherName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarDeveloper extends StatelessWidget {
  const _StarDeveloper({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: YaruColors.orange.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.star,
          color: Colors.white,
        ),
      ),
    );
  }
}
