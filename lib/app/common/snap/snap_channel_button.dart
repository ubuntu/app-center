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
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/snap/snap_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapChannelPopupButton extends StatelessWidget {
  const SnapChannelPopupButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return YaruPopupMenuButton(
      padding: const EdgeInsets.only(left: 15, right: 5),
      initialValue: model.channelToBeInstalled,
      tooltip: context.l10n.channel,
      itemBuilder: (v) => [
        for (int i = 0; i < model.selectableChannels.length; i++)
          PopupMenuItem(
            value: model.getSelectableChannelName(i),
            padding: EdgeInsets.zero,
            onTap: () =>
                model.channelToBeInstalled = model.getSelectableChannelName(i),
            child: _Item(
              name: model.getSelectableChannelName(i),
              version: model.getSelectableChannel(i).version,
              releasedAt: DateFormat.yMd(Platform.localeName).format(
                model.getSelectableChannel(i).releasedAt,
              ),
              apendDivider: i < model.selectableChannels.length - 1,
            ),
          ),
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

class _Item extends StatelessWidget {
  const _Item({
    this.apendDivider = false,
    required this.name,
    required this.version,
    required this.releasedAt,
  });

  final bool apendDivider;
  final String name;
  final String version;
  final String releasedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(
      fontWeight: FontWeight.normal,
      color: theme.hintColor,
    );
    const infoStyle = TextStyle(
      overflow: TextOverflow.ellipsis,
      fontWeight: FontWeight.normal,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.channel,
                      style: labelStyle,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      context.l10n.version,
                      style: labelStyle,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      context.l10n.releasedAt,
                      style: labelStyle,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: infoStyle,
                      maxLines: 1,
                    ),
                    Text(
                      version,
                      style: infoStyle,
                      maxLines: 1,
                    ),
                    Text(
                      releasedAt,
                      style: infoStyle,
                      maxLines: 1,
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        if (apendDivider)
          const Divider(
            height: 0,
          )
      ],
    );
  }
}
