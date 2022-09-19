import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapControls extends StatelessWidget {
  const SnapControls({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    if (model.appChangeInProgress) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: YaruCircularProgressIndicator(
          strokeWidth: 3,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (model.snapIsInstalled)
          OutlinedButton(
            onPressed: model.removeSnap,
            child: Text(context.l10n.remove),
          ),
        if (model.snapIsInstalled)
          OutlinedButton(
            onPressed: model.refreshSnapApp,
            child: Text(
              context.l10n.refresh,
            ),
          )
        else
          ElevatedButton(
            onPressed: model.installSnap,
            child: Text(
              context.l10n.install,
            ),
          ),
        if (model.selectableChannels.isNotEmpty &&
            model.selectableChannels.length > 1)
          PopupMenuButton<String>(
            tooltip: context.l10n.channel,
            onSelected: model.appChangeInProgress
                ? null
                : (v) => model.channelToBeInstalled = v,
            initialValue: model.channelToBeInstalled,
            itemBuilder: (context) {
              return [
                for (final entry in model.selectableChannels.entries)
                  PopupMenuItem(
                    value: entry.key,
                    child: Text(
                      '${entry.key}, ${entry.value.releasedAt}, ${entry.value.version}',
                    ),
                  )
              ];
            },
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(model.channelToBeInstalled),
                const SizedBox(height: 40, child: Icon(YaruIcons.pan_down)),
              ],
            ),
          ),
      ],
    );
  }
}
