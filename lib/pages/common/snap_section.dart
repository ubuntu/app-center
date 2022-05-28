// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
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
  SnapSection.server_and_cloud: YaruIcons.computer,
  SnapSection.social: YaruIcons.subtitles,
  SnapSection.utilities: YaruIcons.utilities,
};
