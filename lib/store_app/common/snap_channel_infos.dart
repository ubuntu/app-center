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

class SnapChannelInfos extends StatelessWidget {
  final String channelToBeInstalled;

  final String releaseAtIsoNorm;

  final String releasedAt;

  const SnapChannelInfos({
    super.key,
    required this.channelToBeInstalled,
    required this.releaseAtIsoNorm,
    required this.releasedAt,
  });

  @override
  Widget build(BuildContext context) {
    return YaruExpandable(
      isExpanded: true,
      expandIcon: const Icon(YaruIcons.pan_end),
      header: Text(
        context.l10n.channel,
        style: Theme.of(context).textTheme.headline6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.channel),
                SelectableText(channelToBeInstalled),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.lastUpdated),
                Tooltip(
                  message: releaseAtIsoNorm,
                  child: SelectableText(releasedAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
