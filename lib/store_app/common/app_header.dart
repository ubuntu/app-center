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
import 'package:software/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class AppHeader extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String summary;
  final bool strict;
  final String confinementName;
  final String version;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final bool verified;
  final String publisherName;
  final String website;
  final Widget? controls;

  const AppHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.summary,
    required this.version,
    required this.strict,
    required this.confinementName,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.verified,
    required this.publisherName,
    required this.website,
    this.controls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 120,
              child: icon,
            ),
            const SizedBox(
              width: 30,
            ),
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.visible,
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (verified)
                          Tooltip(
                            message: context.l10n.verified,
                            child: const Icon(
                              Icons.verified,
                              size: 20,
                              color: YaruColors.success,
                            ),
                          ),
                        if (website.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => launchUrl(Uri.parse(website)),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: verified ? 5 : 0,
                                    right: 5,
                                  ),
                                  child: Text(
                                    publisherName,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(right: verified ? 5 : 0),
                                  child: Icon(
                                    YaruIcons.external_link,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (controls != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: controls!,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        AppInfos(
            strict: strict,
            confinementName: confinementName,
            license: license,
            installDate: installDate,
            installDateIsoNorm: installDateIsoNorm,
            version: version),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
}

class AppInfos extends StatelessWidget {
  const AppInfos({
    Key? key,
    required this.strict,
    required this.confinementName,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.version,
  }) : super(key: key);

  final bool strict;
  final String confinementName;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          children: [
            Text(
              context.l10n.confinement,
              style: headerStyle,
            ),
            Row(
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
          ],
        ),
        const SizedBox(height: 50, width: 30, child: VerticalDivider()),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(context.l10n.license, style: headerStyle),
            ),
            Flexible(
              child: Tooltip(
                message: license,
                child: Text(
                  license.split(' ').first,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 50, width: 30, child: VerticalDivider()),
        Column(
          children: [
            Text(
              installDate.isEmpty
                  ? context.l10n.version
                  : context.l10n.installDate,
              style: headerStyle,
            ),
            Tooltip(
              message: installDateIsoNorm,
              child: Text(
                installDate.isEmpty ? version : installDate,
                style: headerStyle.copyWith(fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
