import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/games/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/small_banner.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.title,
    required this.summary,
    super.key,
    this.onTap,
    this.compact = false,
    this.iconUrl,
    this.footer,
  });

  AppCard.fromSnap({
    required Snap snap,
    VoidCallback? onTap,
  }) : this(
          key: ValueKey(snap.id),
          title: AppTitle.fromSnap(snap),
          summary: snap.summary,
          iconUrl: snap.iconUrl,
          footer: _RatingsInfo(snap: snap),
          onTap: onTap,
        );

  AppCard.fromDeb({
    required AppstreamComponent component,
    VoidCallback? onTap,
  }) : this(
          key: ValueKey(component.id),
          title: AppTitle.fromDeb(component),
          summary: component.getLocalizedSummary(),
          iconUrl: component.icon,
          onTap: onTap,
        );

  AppCard.fromTool({
    required Tool tool,
    Key? key,
  }) : this(
          key: key,
          title: AppTitle.fromTool(tool),
          summary: tool.summary,
          iconUrl: tool.iconUrl,
          footer: OutlinedButton(
            onPressed: () async {
              await launchUrl(Uri.parse(tool.url));
            },
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Text(l10n.openInBrowser);
              },
            ),
          ),
        );

  final AppTitle title;
  final String summary;
  final VoidCallback? onTap;
  final bool compact;
  final String? iconUrl;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardLabel = [
      '${title.title}.',
      title.publisher?.isNotEmpty ?? false
          ? l10n.appCardPublisherSemanticLabel(title.publisher!)
          : null,
      '$summary.',
    ].nonNulls.join(' ');

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: cardLabel,
        child: YaruBanner(
          padding: const EdgeInsets.all(kCardSpacing),
          onTap: onTap,
          child: Flex(
            direction: compact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon(iconUrl: iconUrl),
              const SizedBox(width: kCardSpacing, height: kCardSpacing),
              Expanded(
                child: _AppCardBody(
                  title: title,
                  summary: summary,
                  footer: footer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RankedAppCard extends StatelessWidget {
  const RankedAppCard({
    required this.title,
    required this.summary,
    required this.rank,
    this.onTap,
    this.compact = false,
    this.iconUrl,
    this.footer,
    super.key,
  });

  RankedAppCard.fromRankedSnap({
    required Snap snap,
    required int rank,
    VoidCallback? onTap,
  }) : this(
          key: ValueKey(snap.id),
          title: AppTitle.fromSnap(snap),
          summary: snap.summary,
          iconUrl: snap.iconUrl,
          footer: _RatingsInfo(snap: snap),
          onTap: onTap,
          rank: rank,
        );

  final AppTitle title;
  final String summary;
  final VoidCallback? onTap;
  final bool compact;
  final String? iconUrl;
  final Widget? footer;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final cardLabel = [
      '$rank.',
      '${title.title}.',
      title.publisher?.isNotEmpty ?? false
          ? l10n.appCardPublisherSemanticLabel(title.publisher!)
          : null,
    ].nonNulls.join(' ');

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: cardLabel,
        child: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ExcludeSemantics(
                child: Text(
                  rank.toString(),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Expanded(
              child: SmallBanner(
                onTap: onTap,
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    AppIcon(iconUrl: iconUrl),
                    const SizedBox(width: kCardSpacing, height: kCardSpacing),
                    Expanded(
                      child: _AppCardBody(
                        title: title,
                        summary: '',
                        footer: footer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: generalize
class SnapImageCard extends StatelessWidget {
  const SnapImageCard({required this.snap, super.key, this.onTap});

  final Snap snap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appTitle = AppTitle.fromSnap(snap);

    return Semantics(
      button: true,
      label: appTitle.title,
      child: YaruBanner(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 160, // based on mockups
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(kYaruContainerRadius),
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
                child: _AppCardBody(
                  title: appTitle,
                  summary: snap.summary,
                  footer: _RatingsInfo(snap: snap),
                  maxlines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppCardBody extends StatelessWidget {
  const _AppCardBody({
    required this.title,
    required this.summary,
    this.footer,
    this.maxlines = 2,
  });

  final Widget title;
  final String summary;
  final Widget? footer;
  final int maxlines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Container(
            constraints: BoxConstraints(minHeight: kIconSize),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: title,
            ),
          ),
        ),
        if (summary.isNotEmpty) ...[
          const SizedBox(height: 12),
          Flexible(
            child: ExcludeSemantics(
              child: Text(
                '$summary\n',
                maxLines: maxlines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        if (footer != null) ...[
          const SizedBox(height: 8),
          footer!,
        ],
      ],
    );
  }
}

class _RatingsInfo extends ConsumerWidget {
  const _RatingsInfo({required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsModel = ref.watch(ratingsModelProvider(snap.name));
    final l10n = AppLocalizations.of(context);

    return ratingsModel.when(
      data: (ratingsData) {
        final rating = ratingsData.rating;
        final ratingLabel = rating?.ratingsBand.localize(l10n) ?? ' ';
        final votesLabel = l10n.snapRatingsVotes(rating?.totalVotes ?? 0);

        return Wrap(
          children: [
            Semantics(
              label: l10n.appCardRatingSemanticLabel(ratingLabel),
              excludeSemantics: true,
              child: Text(
                ratingLabel,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: rating?.ratingsBand.getColor(context),
                      fontSize: 12,
                    ),
              ),
            ),
            const SizedBox(width: 2),
            if (rating?.totalVotes != null) ...[
              const SizedBox(width: 2),
              Semantics(
                label: votesLabel,
                excludeSemantics: true,
                child: Text(
                  ' | $votesLabel',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
