import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/layout.dart';
import '/ratings.dart';
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
        _RatingsInfo(snapId: snap.id),
      ],
    );
  }
}

class _RatingsInfo extends ConsumerWidget {
  const _RatingsInfo({required this.snapId});

  final String snapId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsModel = ref.watch(ratingsModelProvider(snapId));
    final l10n = AppLocalizations.of(context);

    return ratingsModel.state.when(
      data: (ratingsData) {
        final rating = ratingsModel.snapRating;
        return Wrap(
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
                ' | ${l10n.snapRatingsVotes(rating?.totalVotes ?? 0)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        );
      },
      error: (error, stackTrace) => const Text(''),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}
