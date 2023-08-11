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
      padding: const EdgeInsets.all(kCardSpacing),
      onTap: onTap,
      child: Flex(
        direction: compact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SnapIcon(iconUrl: snap.iconUrl),
          const SizedBox(width: 16, height: 16),
          Expanded(child: _SnapCardBody(snap: snap)),
        ],
      ),
    );
  }
}

class SnapImageCard extends StatelessWidget {
  const SnapImageCard({super.key, required this.snap, this.onTap});

  final Snap snap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return YaruBanner(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 160, // based on mockups
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(kYaruBannerRadius),
              ),
              child: SafeNetworkImage(
                url: snap.screenshotUrls.first,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 306 - 160, // based on mockups
            child: Padding(
              padding: const EdgeInsets.all(kCardSpacing),
              child: _SnapCardBody(snap: snap, maxlines: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapCardBody extends StatelessWidget {
  const _SnapCardBody({required this.snap, this.maxlines = 2});

  final Snap snap;
  final int maxlines;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            maxLines: maxlines,
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
    );
  }
}
