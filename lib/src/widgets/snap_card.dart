import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/layout.dart';
import '/snapd.dart';
import '/widgets.dart';
import '../../l10n.dart';
import '../ratings/exports.dart';
import '../ratings/ratings_l10n.dart';

class SnapCard extends StatelessWidget {
  SnapCard({
    super.key,
    required this.snap,
    required this.rating,
    this.onTap,
    this.compact = false,
  });

  final Snap snap;
  final VoidCallback? onTap;
  final bool compact;
  Rating? rating;

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
          Expanded(child: _SnapCardBody(snap: snap, rating: rating)),
        ],
      ),
    );
  }
}

class SnapImageCard extends StatelessWidget {
  SnapImageCard(
      {super.key, required this.snap, this.onTap, required this.rating});

  final Snap snap;
  final VoidCallback? onTap;
  Rating? rating;

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
              child: _SnapCardBody(
                snap: snap,
                maxlines: 1,
                rating: rating,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapCardBody extends StatelessWidget {
  _SnapCardBody({required this.snap, this.maxlines = 2, required this.rating});

  final Snap snap;
  final int maxlines;
  Rating? rating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        Wrap(
          children: [
            Text(
              rating?.ratingsBand.localize(l10n) ?? ' ',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: rating?.ratingsBand.getColor(context),
                    fontSize: 12,
                  ),
            ),
            const SizedBox(width: 2),
            if (rating?.totalVotes != null) ...[
              const SizedBox(width: 2),
              Text(
                ' | ${rating?.totalVotes} ${l10n.snapRatingsVotes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
