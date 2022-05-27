import 'package:flutter/widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';

enum SnapSection {
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
  utilities;
}

Map<SnapSection, IconData> snapSectionToIcon = {
  SnapSection.artAndDesign: YaruIcons.template,
  SnapSection.booksAndReference: YaruIcons.book,
  SnapSection.development: YaruIcons.wrench,
  SnapSection.devicesAndIot: YaruIcons.chip,
  SnapSection.education: YaruIcons.education,
  SnapSection.entertainment: YaruIcons.television,
  SnapSection.featured: YaruIcons.star,
  SnapSection.finance: YaruIcons.calculator,
  SnapSection.games: YaruIcons.games,
  SnapSection.healthAndFitness: YaruIcons.health,
  SnapSection.musicAndAudio: YaruIcons.headphones,
  SnapSection.newsAndWeather: YaruIcons.weather_storm,
  SnapSection.personalisation: YaruIcons.desktop_appearance,
  SnapSection.photoAndVideo: YaruIcons.camera_photo,
  SnapSection.productivity: YaruIcons.clock,
  SnapSection.science: YaruIcons.beaker,
  SnapSection.security: YaruIcons.shield,
  SnapSection.serverAndCloud: YaruIcons.computer,
  SnapSection.social: YaruIcons.subtitles,
  SnapSection.utilities: YaruIcons.utilities,
};
