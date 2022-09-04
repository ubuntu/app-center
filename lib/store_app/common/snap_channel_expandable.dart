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

class SnapChannelExpandable extends StatelessWidget {
  const SnapChannelExpandable({
    super.key,
    required this.onInit,
    required this.selectableChannelsIsEmpty,
    required this.channelToBeInstalled,
    required this.selectableChannels,
    required this.releasedAt,
    required this.releaseAtIsoNorm,
    required this.selectedChannelVersion,
    this.onChanged,
  });

  final Function() onInit;
  final bool selectableChannelsIsEmpty;
  final String channelToBeInstalled;
  final List<String> selectableChannels;
  final String releasedAt;
  final String releaseAtIsoNorm;
  final String selectedChannelVersion;
  final Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return selectableChannelsIsEmpty
        ? Row(
            children: [
              YaruRoundIconButton(
                onTap: onInit,
                child: const Icon(YaruIcons.refresh),
              )
            ],
          )
        : YaruExpandable(
            isExpanded: true,
            expandIcon: const Icon(YaruIcons.pan_end),
            header: DropdownButton<String>(
              icon: const Icon(YaruIcons.pan_down),
              borderRadius: BorderRadius.circular(10),
              elevation: 1,
              value: channelToBeInstalled,
              items: [
                for (final entry in selectableChannels)
                  DropdownMenuItem<String>(
                    value: entry,
                    child: Text(
                      '${context.l10n.channel}: $entry',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
              onChanged: onChanged,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.version),
                      SelectableText(selectedChannelVersion),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
