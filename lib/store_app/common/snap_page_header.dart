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
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class SnapPageHeader extends StatelessWidget {
  final String iconUrl;
  final String title;
  final String summary;
  final bool snapIsInstalled;
  final bool connectionsExpanded;
  final bool connectionsNotEmpty;
  final bool strict;
  final String confinementName;
  final String version;
  final String license;
  final String installDate;
  final String installDateIsoNorm;

  final Function() open;
  final Function() onConnectionsExpanded;

  const SnapPageHeader({
    super.key,
    required this.iconUrl,
    required this.title,
    required this.summary,
    required this.snapIsInstalled,
    required this.version,
    required this.open,
    required this.connectionsExpanded,
    required this.strict,
    required this.confinementName,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.connectionsNotEmpty,
    required this.onConnectionsExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 65,
              child: YaruSafeImage(
                url: iconUrl,
                fallBackIconData: YaruIcons.package_snap,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            SizedBox(
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      // if (snapIsInstalled)
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.caption,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                  if (snapIsInstalled)
                    SizedBox(
                      height: 30,
                      child: Row(
                        children: [
                          YaruRoundIconButton(
                            size: 30,
                            tooltip: version,
                            child: const Icon(
                              YaruIcons.ok_filled,
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          YaruRoundIconButton(
                            size: 30,
                            tooltip: context.l10n.open,
                            onTap: open,
                            child: Icon(
                              YaruIcons.external_link,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          if (snapIsInstalled && connectionsNotEmpty)
                            YaruRoundIconButton(
                              size: 30,
                              backgroundColor: connectionsExpanded
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.05)
                                  : Colors.transparent,
                              tooltip: context.l10n.connections,
                              onTap: onConnectionsExpanded,
                              child: Icon(
                                YaruIcons.lock,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                            )
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
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
            SizedBox(
              width: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
            ),
            const SizedBox(height: 50, width: 30, child: VerticalDivider()),
            Column(
              children: [
                Text(context.l10n.installDate, style: headerStyle),
                Tooltip(
                  message: installDateIsoNorm,
                  child: Text(
                    installDate.isNotEmpty
                        ? installDate
                        : context.l10n.notInstalled,
                    style: headerStyle.copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
