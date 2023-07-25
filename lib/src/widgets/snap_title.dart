import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

import '/snapd.dart';

class SnapTitle extends StatelessWidget {
  const SnapTitle({
    super.key,
    required this.snap,
    this.large = false,
  });

  const SnapTitle.large({super.key, required this.snap}) : large = true;

  final Snap snap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final titleTextStyle =
        large ? textTheme.headlineSmall! : textTheme.titleMedium!;
    final publisherTextStyle =
        large ? textTheme.bodyMedium! : textTheme.bodyMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          snap.titleOrName,
          style: titleTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                snap.publisher?.displayName ?? l10n.unknownPublisher,
                style: publisherTextStyle.copyWith(
                    color: Theme.of(context).hintColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (snap.verifiedPublisher || snap.starredPublisher)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Icon(
                  snap.verifiedPublisher ? Icons.verified : Icons.stars,
                  size: publisherTextStyle.fontSize,
                  color: snap.verifiedPublisher
                      ? Theme.of(context).colorScheme.success
                      : Theme.of(context).colorScheme.warning,
                ),
              ),
          ],
        ),
        if (large) ...[
          const SizedBox(height: 8),
          Row(
            children: snap.categories
                .whereNot((c) => c.name == 'featured')
                .map((c) => Text(c.localize(l10n)))
                .separatedBy(const Text(', ')),
          )
        ]
      ],
    );
  }
}

extension on Iterable<Widget> {
  List<Widget> separatedBy(Widget separator) => [
        for (var i = 0; i < length; i++) ...[
          elementAt(i),
          if (i < length - 1) separator,
        ]
      ];
}

extension SnapCategoryL10n on SnapCategory {
  String localize(AppLocalizations l10n) {
    return switch (name) {
      'art-and-design' => l10n.snapCategoryArtAndDesign,
      'books-and-reference' => l10n.snapCategoryBooksAndReference,
      'development' => l10n.snapCategoryDevelopment,
      'devices-and-iot' => l10n.snapCategoryDevicesAndIot,
      'education' => l10n.snapCategoryEducation,
      'entertainment' => l10n.snapCategoryEntertainment,
      'featured' => l10n.snapCategoryFeatured,
      'finance' => l10n.snapCategoryFinance,
      'games' => l10n.snapCategoryGames,
      'health-and-fitness' => l10n.snapCategoryHealthAndFitness,
      'music-and-audio' => l10n.snapCategoryMusicAndAudio,
      'news-and-weather' => l10n.snapCategoryNewsAndWeather,
      'personalisation' => l10n.snapCategoryPersonalisation,
      'photo-and-video' => l10n.snapCategoryPhotoAndVideo,
      'productivity' => l10n.snapCategoryProductivity,
      'science' => l10n.snapCategoryScience,
      'security' => l10n.snapCategorySecurity,
      'server-and-cloud' => l10n.snapCategoryServerAndCloud,
      'social' => l10n.snapCategorySocial,
      'utilities' => l10n.snapCategoryUtilities,
      _ => name
    };
  }
}
