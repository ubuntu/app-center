import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapChannelExpandable extends StatelessWidget {
  const SnapChannelExpandable({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return model.selectableChannels.isEmpty
        ? Row(
            children: [
              YaruRoundIconButton(
                child: const Icon(YaruIcons.refresh),
                onTap: () => model.init(),
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
              value: model.channelToBeInstalled,
              items: [
                for (final entry in model.selectableChannels.entries)
                  DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      '${context.l10n.channel}: ${entry.key}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
              onChanged: model.appChangeInProgress
                  ? null
                  : (v) => model.channelToBeInstalled = v!,
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
                      SelectableText(model.selectedChannelVersion ?? ''),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.lastUpdated),
                      SelectableText(model.releasedAt),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
