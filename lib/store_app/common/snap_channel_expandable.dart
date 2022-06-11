import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
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

    return YaruExpandable(
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
        children: [
          YaruSingleInfoRow(
            infoLabel: context.l10n.version,
            infoValue: model.selectedChannelVersion ?? '',
          ),
          YaruSingleInfoRow(
            infoLabel: context.l10n.lastUpdated,
            infoValue: model.releasedAt,
          ),
        ],
      ),
    );
  }
}
