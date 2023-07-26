import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/layout.dart';
import '/snapd.dart';
import '/widgets.dart';

class SnapCard extends StatelessWidget {
  const SnapCard({
    super.key,
    required this.snap,
    this.onTap,
    this.compact = false,
  });

  final Snap snap;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return YaruBanner(
      padding: const EdgeInsets.all(kPagePadding),
      onTap: onTap,
      child: Flex(
        direction: compact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnapIcon(iconUrl: snap.iconUrl),
          const SizedBox(width: 16, height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: kIconSize,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SnapTitle(snap: snap),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    snap.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                // TODO: ratings
                Wrap(
                  children: [
                    Text(
                      'Positive',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.success,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Text('|', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 2),
                    Text(
                      '200 Ratings',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
