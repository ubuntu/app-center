/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

enum SnapSection {
  all,
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
      case SnapSection.all:
        return l10n.all;
      default:
        return title;
    }
  }

  String slogan(AppLocalizations l10n) {
    switch (this) {
      case SnapSection.art_and_design:
        return l10n.artAndDesignSlogan;
      case SnapSection.books_and_reference:
        return l10n.booksAndReferenceSlogan;
      case SnapSection.development:
        return l10n.developmentSlogan;
      case SnapSection.devices_and_iot:
        return l10n.devicesAndIotSlogan;
      case SnapSection.education:
        return l10n.educationSlogan;
      case SnapSection.entertainment:
        return l10n.entertainmentSlogan;
      case SnapSection.featured:
        return l10n.featuredSlogan;
      case SnapSection.finance:
        return l10n.financeSlogan;
      case SnapSection.games:
        return l10n.gamesSlogan;
      case SnapSection.health_and_fitness:
        return l10n.healthAndFitnessSlogan;
      case SnapSection.music_and_audio:
        return l10n.musicAndAudioSlogan;
      case SnapSection.news_and_weather:
        return l10n.newsAndWeatherSlogan;
      case SnapSection.personalisation:
        return l10n.personalisationSlogan;
      case SnapSection.photo_and_video:
        return l10n.photoAndVideoSlogan;
      case SnapSection.productivity:
        return l10n.productivitySlogan;
      case SnapSection.science:
        return l10n.scienceSlogan;
      case SnapSection.security:
        return l10n.securitySlogan;
      case SnapSection.server_and_cloud:
        return l10n.serverAndCloudSlogan;
      case SnapSection.social:
        return l10n.socialSlogan;
      case SnapSection.utilities:
        return l10n.utilitiesSlogan;
      case SnapSection.all:
        return l10n.featuredSlogan;
    }
  }

  // TODO: @madsrh please add colors
  // Those are normal hex plus the leading FF for alpha, just leave FF
  // or take colors from YaruColors
  List<int> get colors {
    switch (this) {
      case SnapSection.art_and_design:
        return [0xFF12c2e9, 0xFFf64f59];
      case SnapSection.books_and_reference:
        return [
          const Color.fromARGB(255, 59, 54, 54).value,
          const Color.fromARGB(108, 0, 114, 229).value
        ];
      case SnapSection.development:
        return [
          const Color.fromARGB(255, 113, 80, 151).value,
          const Color.fromARGB(255, 165, 26, 146).value
        ];
      case SnapSection.devices_and_iot:
        return [
          const Color.fromARGB(255, 71, 71, 71).value,
          YaruColors.red.value
        ];
      case SnapSection.education:
        return [
          const Color.fromARGB(255, 71, 71, 71).value,
          YaruColors.magenta.value
        ];
      case SnapSection.entertainment:
        return [
          const Color.fromARGB(255, 163, 98, 12).value,
          const Color.fromARGB(255, 255, 137, 26).value
        ];
      case SnapSection.featured:
        return [
          const Color.fromARGB(255, 167, 92, 22).value,
          const Color.fromARGB(255, 133, 1, 122).value
        ];
      case SnapSection.finance:
        return [
          const Color.fromARGB(255, 71, 71, 71).value,
          YaruColors.purple.value
        ];
      case SnapSection.games:
        return [
          const Color.fromARGB(255, 25, 119, 96).value,
          const Color.fromARGB(255, 135, 3, 124).value
        ];
      case SnapSection.health_and_fitness:
        return [
          const Color.fromARGB(255, 86, 23, 122).value,
          YaruColors.warning.value
        ];
      case SnapSection.music_and_audio:
        return [
          const Color.fromARGB(255, 119, 10, 43).value,
          const Color.fromARGB(157, 233, 0, 58).value
        ];
      case SnapSection.news_and_weather:
        return [
          const Color.fromARGB(255, 165, 115, 44).value,
          const Color.fromARGB(255, 255, 219, 101).value
        ];
      case SnapSection.personalisation:
        return [
          const Color.fromARGB(255, 35, 12, 139).value,
          const Color.fromARGB(255, 25, 173, 166).value
        ];
      case SnapSection.photo_and_video:
        return [
          const Color.fromARGB(255, 71, 71, 71).value,
          const Color.fromARGB(255, 133, 133, 133).value
        ];
      case SnapSection.productivity:
        return [const Color(0xFF712290).value, const Color(0xFFff5733).value];
      case SnapSection.science:
        return [
          const Color.fromARGB(255, 71, 71, 71).value,
          YaruColors.orange.value
        ];
      case SnapSection.security:
        return [
          const Color.fromARGB(255, 16, 40, 49).value,
          const Color.fromARGB(255, 19, 131, 112).value
        ];
      case SnapSection.server_and_cloud:
        return [
          const Color.fromARGB(255, 71, 28, 10).value,
          YaruColors.orange.value
        ];
      case SnapSection.social:
        return [
          const Color.fromARGB(255, 11, 73, 59).value,
          const Color.fromARGB(255, 15, 122, 87).value
        ];
      case SnapSection.utilities:
        return [
          const Color.fromARGB(136, 82, 74, 40).value,
          const Color.fromARGB(155, 233, 203, 34).value
        ];
      case SnapSection.all:
        return [
          const Color.fromARGB(255, 167, 92, 22).value,
          const Color.fromARGB(255, 133, 1, 122).value
        ];
    }
  }
}

Map<SnapSection, IconData> snapSectionToIcon = {
  SnapSection.art_and_design: YaruIcons.rule_and_pen,
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
  SnapSection.news_and_weather: YaruIcons.storm,
  SnapSection.personalisation: YaruIcons.desktop_appearance,
  SnapSection.photo_and_video: YaruIcons.camera_photo,
  SnapSection.productivity: YaruIcons.clock,
  SnapSection.science: YaruIcons.beaker,
  SnapSection.security: YaruIcons.shield,
  SnapSection.server_and_cloud: YaruIcons.cloud,
  SnapSection.social: YaruIcons.subtitles,
  SnapSection.utilities: YaruIcons.swiss_knife,
  SnapSection.all: YaruIcons.app_grid
};
