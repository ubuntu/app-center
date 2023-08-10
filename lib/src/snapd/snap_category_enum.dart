import 'package:flutter/widgets.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '/l10n.dart';

extension SnapCategoryX on SnapCategory {
  SnapCategoryEnum get categoryEnum => name.toSnapCategoryEnum();
}

extension StringX on String {
  SnapCategoryEnum toSnapCategoryEnum() => SnapCategoryEnum.values.byName(
        replaceAllMapped(
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
        artAndDesign =>
          selected ? YaruIcons.rule_and_pen_filled : YaruIcons.rule_and_pen,
        booksAndReference => selected ? YaruIcons.book_filled : YaruIcons.book,
        development => YaruIcons.wrench,
        devicesAndIot => selected ? YaruIcons.chip_filled : YaruIcons.chip,
        education =>
          selected ? YaruIcons.education_filled : YaruIcons.education,
        entertainment =>
          selected ? YaruIcons.television_filled : YaruIcons.television,
        featured => selected ? YaruIcons.star_filled : YaruIcons.star,
        finance => YaruIcons.calculator,
        games => selected ? YaruIcons.games_filled : YaruIcons.games,
        healthAndFitness =>
          selected ? YaruIcons.health_filled : YaruIcons.health,
        musicAndAudio => YaruIcons.headphones,
        newsAndWeather => selected ? YaruIcons.storm_filled : YaruIcons.storm,
        personalisation => selected
            ? YaruIcons.desktop_appearance_filled
            : YaruIcons.desktop_appearance,
        photoAndVideo =>
          selected ? YaruIcons.camera_photo_filed : YaruIcons.camera_photo,
        productivity => selected ? YaruIcons.clock_filled : YaruIcons.clock,
        science => selected ? YaruIcons.beaker_filled : YaruIcons.beaker,
        security => selected ? YaruIcons.shield_filled : YaruIcons.shield,
        serverAndCloud => selected ? YaruIcons.cloud_filled : YaruIcons.cloud,
        social => selected ? YaruIcons.chat_text_filled : YaruIcons.chat_text,
        utilities =>
          selected ? YaruIcons.swiss_knife_filled : YaruIcons.swiss_knife,
        _ => YaruIcons.application,
      };
}
