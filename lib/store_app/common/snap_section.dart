// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

enum SnapSection {
  art_and_design,
  books_and_reference,
  development,
  devices_and_iot,
  education,
  entertainment,
  featured,
  finance,
  games,
  health_and_fitness,
  music_and_audio,
  news_and_weather,
  personalisation,
  photo_and_video,
  productivity,
  science,
  security,
  server_and_cloud,
  social,
  utilities;

  String get title => name.replaceAll('_', '-');

  String localize(AppLocalizations l10n) {
    switch (this) {
      case SnapSection.art_and_design:
        return l10n.artAndDesign;
      case SnapSection.books_and_reference:
        return l10n.booksAndReference;
      case SnapSection.development:
        return l10n.development;
      case SnapSection.devices_and_iot:
        return l10n.devicesAndIot;
      case SnapSection.education:
        return l10n.education;
      case SnapSection.entertainment:
        return l10n.entertainment;
      case SnapSection.featured:
        return l10n.featured;
      case SnapSection.finance:
        return l10n.finance;
      case SnapSection.games:
        return l10n.games;
      case SnapSection.health_and_fitness:
        return l10n.healthAndFitness;
      case SnapSection.music_and_audio:
        return l10n.musicAndAudio;
      case SnapSection.news_and_weather:
        return l10n.newsAndWeather;
      case SnapSection.personalisation:
        return l10n.personalisation;
      case SnapSection.photo_and_video:
        return l10n.photoAndVideo;
      case SnapSection.productivity:
        return l10n.productivity;
      case SnapSection.science:
        return l10n.science;
      case SnapSection.security:
        return l10n.security;
      case SnapSection.server_and_cloud:
        return l10n.serverAndCloud;
      case SnapSection.social:
        return l10n.social;
      case SnapSection.utilities:
        return l10n.utilities;
      default:
        return title;
    }
  }
}

Map<SnapSection, IconData> snapSectionToIcon = {
  SnapSection.art_and_design: YaruIcons.template,
  SnapSection.books_and_reference: YaruIcons.book,
  SnapSection.development: YaruIcons.wrench,
  SnapSection.devices_and_iot: YaruIcons.chip,
  SnapSection.education: YaruIcons.education,
  SnapSection.entertainment: YaruIcons.television,
  SnapSection.featured: YaruIcons.star,
  SnapSection.finance: YaruIcons.calculator,
  SnapSection.games: YaruIcons.games,
  SnapSection.health_and_fitness: YaruIcons.health,
  SnapSection.music_and_audio: YaruIcons.headphones,
  SnapSection.news_and_weather: YaruIcons.weather_storm,
  SnapSection.personalisation: YaruIcons.desktop_appearance,
  SnapSection.photo_and_video: YaruIcons.camera_photo,
  SnapSection.productivity: YaruIcons.clock,
  SnapSection.science: YaruIcons.beaker,
  SnapSection.security: YaruIcons.shield,
  SnapSection.server_and_cloud: YaruIcons.weather_cloudy,
  SnapSection.social: YaruIcons.subtitles,
  SnapSection.utilities: YaruIcons.utilities,
};
