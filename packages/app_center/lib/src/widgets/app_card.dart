import 'package:app_center/appstream.dart';
import 'package:app_center/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/ratings.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/widgets.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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

  factory AppCard.fromSnap({
    required Snap snap,
    VoidCallback? onTap,
  }) =>
      AppCard(
        key: ValueKey(snap.id),
        title: AppTitle.fromSnap(snap),
        summary: snap.summary,
        iconUrl: snap.iconUrl,
        footer: _RatingsInfo(snap: snap),
        onTap: onTap,
      );

  factory AppCard.fromDeb({
    required AppstreamComponent component,
    VoidCallback? onTap,
  }) =>
      AppCard(
        key: ValueKey(component.id),
        title: AppTitle.fromDeb(component),
        summary: component.getLocalizedSummary(),
        iconUrl: component.icon,
        onTap: onTap,
      );

  factory AppCard.fromTool({
    required Tool tool,
  }) =>
      AppCard(
        title: AppTitle.fromTool(tool),
        summary: tool.summary,
        iconUrl: tool.iconUrl,
        footer: OutlinedButton(
          onPressed: () async {
            await launchUrl(Uri.parse(tool.url));
          },
          child: Builder(builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Text(l10n.openInBrowser);
          }),
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
    return YaruBanner(
      padding: const EdgeInsets.all(kCardSpacing),
      onTap: onTap,
      child: Flex(
        direction: compact ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(iconUrl: iconUrl),
          const SizedBox(width: 16, height: 16),
          Expanded(
              child: _AppCardBody(
            title: title,
            summary: summary,
            footer: footer,
          )),
        ],
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
              child: _AppCardBody(
                title: AppTitle.fromSnap(snap),
                summary: snap.summary,
                footer: _RatingsInfo(snap: snap),
                maxlines: 1,
              ),
            ),
          ),
        ],
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
        SizedBox(
          height: kIconSize,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: title,
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: Text(
            summary,
            maxLines: maxlines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 8),
          footer!,
        ]
      ],
    );
  }
}

class _RatingsInfo extends ConsumerWidget {
  const _RatingsInfo({required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsModel = ref.watch(ratingsModelProvider(snap));
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
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
