import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/snapx.dart';
import 'snap_icon.dart';

class SnapCard extends StatelessWidget {
  const SnapCard({super.key, required this.snap, this.onTap});

  final Snap snap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return YaruBanner(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnapIcon(iconUrl: snap.iconUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snap.name),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      snap.publisher?.displayName ?? '?',
                      style: TextStyle(color: Theme.of(context).hintColor),
                      maxLines: 1,
                    ),
                    if (snap.verifiedPublisher || snap.starredPublisher)
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                        child: Icon(
                          snap.verifiedPublisher ? Icons.verified : Icons.stars,
                          size: 12,
                          color: snap.verifiedPublisher
                              ? Theme.of(context).colorScheme.success
                              : Theme.of(context).colorScheme.warning,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    snap.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
