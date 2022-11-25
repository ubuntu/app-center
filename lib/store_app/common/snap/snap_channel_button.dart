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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../../l10n/l10n.dart';
import '../constants.dart';
import 'snap_model.dart';

class SnapChannelPopupButton extends StatelessWidget {
  const SnapChannelPopupButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    final channelTextTheme = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w500);
    final light = Theme.of(context).brightness == Brightness.light;

    return YaruPopupMenuButton(
      initialValue: model.channelToBeInstalled,
      tooltip: context.l10n.channel,
      itemBuilder: (v) => [
        for (final entry in model.selectableChannels.entries)
          PopupMenuItem(
            value: entry.key,
            padding: EdgeInsets.zero,
            child: ListTile(
              dense: true,
              isThreeLine: true,
              onTap: () {
                model.channelToBeInstalled = entry.key;
                Navigator.of(context).pop();
              },
              subtitle: Text(
                entry.key,
                style: channelTextTheme,
              ),
              title: Text(
                DateFormat.yMMMMd(Platform.localeName)
                    .format(entry.value.releasedAt),
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
              trailing: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180, minWidth: 80),
                child: Text(
                  entry.value.version,
                  style: channelTextTheme,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          )
      ],
      child: Text(
        model.channelToBeInstalled,
        style: model.selectedChannelVersion != model.version
            ? TextStyle(color: light ? kGreenLight : kGreenDark)
            : null,
      ),
    );
  }
}
