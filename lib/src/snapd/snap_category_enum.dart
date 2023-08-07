import 'package:flutter/widgets.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '/l10n.dart';

extension SnapCategoryX on SnapCategory {
  SnapCategoryEnum get categoryEnum => SnapCategoryEnum.values.byName(
        name.replaceAllMapped(
          RegExp(r'-(.)'),
          (match) => match[1]!.toUpperCase(),
        ),
      );
}

enum SnapCategoryEnum {
  artAndDesign,
  booksAndReference,
  development,
  devicesAndIot,
  education,
  entertainment,
  featured,
  finance,
  games,
  healthAndFitness,
  musicAndAudio,
  newsAndWeather,
  personalisation,
  photoAndVideo,
  productivity,
  science,
  security,
  serverAndCloud,
  social,
  utilities,
  unknown;

  String get categoryName => name.replaceAllMapped(
      RegExp(r'[A-Z]'), (match) => '-${match[0]!.toLowerCase()}');

  String localize(AppLocalizations l10n) => switch (this) {
        artAndDesign => l10n.snapCategoryArtAndDesign,
        booksAndReference => l10n.snapCategoryBooksAndReference,
        development => l10n.snapCategoryDevelopment,
        devicesAndIot => l10n.snapCategoryDevicesAndIot,
        education => l10n.snapCategoryEducation,
        entertainment => l10n.snapCategoryEntertainment,
        featured => l10n.snapCategoryFeatured,
        finance => l10n.snapCategoryFinance,
        games => l10n.snapCategoryGames,
        healthAndFitness => l10n.snapCategoryHealthAndFitness,
        musicAndAudio => l10n.snapCategoryMusicAndAudio,
        newsAndWeather => l10n.snapCategoryNewsAndWeather,
        personalisation => l10n.snapCategoryPersonalisation,
        photoAndVideo => l10n.snapCategoryPhotoAndVideo,
        productivity => l10n.snapCategoryProductivity,
        science => l10n.snapCategoryScience,
        security => l10n.snapCategorySecurity,
        serverAndCloud => l10n.snapCategoryServerAndCloud,
        social => l10n.snapCategorySocial,
        utilities => l10n.snapCategoryUtilities,
        _ => name
      };

  String slogan(AppLocalizations l10n) => switch (this) {
        development => l10n.snapCategoryDevelopmentSlogan,
        _ => '',
      };

  IconData getIcon(bool selected) => switch (this) {
        development => YaruIcons.wrench,
        games => selected ? YaruIcons.games_filled : YaruIcons.games,
        productivity => selected ? YaruIcons.send_filled : YaruIcons.send,
        _ => YaruIcons.application,
      };
}
