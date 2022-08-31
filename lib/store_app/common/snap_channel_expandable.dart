import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    required this.selectedChannelVersion,
    this.onChanged,
  });

  final Function() onInit;
  final bool selectableChannelsIsEmpty;
  final String channelToBeInstalled;
  final List<String> selectableChannels;
  final DateTime? releasedAt;
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
                        message: releasedAt != null
                            ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(releasedAt!)
                            : null,
                        child: SelectableText(
                          releasedAt != null
                              ? DateFormat.yMMMEd(Platform.localeName)
                                  .format(releasedAt!)
                              : '',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
