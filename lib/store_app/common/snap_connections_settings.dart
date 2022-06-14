import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapConnectionsSettings extends StatelessWidget {
  const SnapConnectionsSettings({super.key, required this.connections});

  final Map<String, SnapConnection> connections;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: YaruExpandable(
        isExpanded: true,
        header: Text(
          context.l10n.connections,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        expandIcon: const Icon(YaruIcons.pan_end),
        child: Column(
          children: [
            if (connections.isNotEmpty)
              for (final connection in connections.entries)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(connection.key),
                      Switch(
                        value: true,
                        onChanged: (v) {},
                      )
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
