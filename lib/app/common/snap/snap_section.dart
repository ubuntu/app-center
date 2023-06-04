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

  String localize(AppLocalizations l10n) => switch (this) {
        SnapSection.art_and_design => l10n.artAndDesign,
        SnapSection.books_and_reference => l10n.booksAndReference,
        SnapSection.development => l10n.development,
        SnapSection.devices_and_iot => l10n.devicesAndIot,
        SnapSection.education => l10n.education,
        SnapSection.entertainment => l10n.entertainment,
        SnapSection.featured => l10n.featured,
        SnapSection.finance => l10n.finance,
        SnapSection.games => l10n.games,
        SnapSection.health_and_fitness => l10n.healthAndFitness,
        SnapSection.music_and_audio => l10n.musicAndAudio,
        SnapSection.news_and_weather => l10n.newsAndWeather,
        SnapSection.personalisation => l10n.personalisation,
        SnapSection.photo_and_video => l10n.photoAndVideo,
        SnapSection.productivity => l10n.productivity,
        SnapSection.science => l10n.science,
        SnapSection.security => l10n.security,
        SnapSection.server_and_cloud => l10n.serverAndCloud,
        SnapSection.social => l10n.social,
        SnapSection.utilities => l10n.utilities,
        SnapSection.all => l10n.all,
      };

  String slogan(AppLocalizations l10n) => switch (this) {
        SnapSection.art_and_design => l10n.artAndDesignSlogan,
        SnapSection.books_and_reference => l10n.booksAndReferenceSlogan,
        SnapSection.development => l10n.developmentSlogan,
        SnapSection.devices_and_iot => l10n.devicesAndIotSlogan,
        SnapSection.education => l10n.educationSlogan,
        SnapSection.entertainment => l10n.entertainmentSlogan,
        SnapSection.featured => l10n.featuredSlogan,
        SnapSection.finance => l10n.financeSlogan,
        SnapSection.games => l10n.gamesSlogan,
        SnapSection.health_and_fitness => l10n.healthAndFitnessSlogan,
        SnapSection.music_and_audio => l10n.musicAndAudioSlogan,
        SnapSection.news_and_weather => l10n.newsAndWeatherSlogan,
        SnapSection.personalisation => l10n.personalisationSlogan,
        SnapSection.photo_and_video => l10n.photoAndVideoSlogan,
        SnapSection.productivity => l10n.productivitySlogan,
        SnapSection.science => l10n.scienceSlogan,
        SnapSection.security => l10n.securitySlogan,
        SnapSection.server_and_cloud => l10n.serverAndCloudSlogan,
        SnapSection.social => l10n.socialSlogan,
        SnapSection.utilities => l10n.utilitiesSlogan,
        SnapSection.all => l10n.featuredSlogan
      };

  List<int> get colors => switch (this) {
        SnapSection.art_and_design => [
            const Color.fromARGB(255, 0, 5, 148).value,
            const Color.fromARGB(255, 255, 155, 179).value
          ],
        SnapSection.books_and_reference => [
            const Color.fromARGB(255, 59, 54, 54).value,
            const Color.fromARGB(108, 0, 114, 229).value
          ],
        SnapSection.development => [
            const Color.fromARGB(255, 54, 0, 80).value,
            const Color.fromARGB(255, 225, 59, 149).value
          ],
        SnapSection.devices_and_iot => [
            const Color.fromARGB(255, 71, 71, 71).value,
            YaruColors.red.value
          ],
        SnapSection.education => [
            const Color.fromARGB(255, 71, 71, 71).value,
            YaruColors.magenta.value
          ],
        SnapSection.entertainment => [
            const Color.fromARGB(255, 163, 98, 12).value,
            const Color.fromARGB(255, 255, 137, 26).value
          ],
        SnapSection.featured => [
            const Color.fromARGB(255, 167, 92, 22).value,
            const Color.fromARGB(255, 133, 1, 122).value
          ],
        SnapSection.finance => [
            const Color.fromARGB(255, 71, 71, 71).value,
            YaruColors.purple.value
          ],
        SnapSection.games => [
            const Color.fromARGB(255, 180, 22, 1).value,
            const Color.fromARGB(255, 254, 172, 12).value
          ],
        SnapSection.health_and_fitness => [
            const Color.fromARGB(255, 86, 23, 122).value,
            YaruColors.warning.value
          ],
        SnapSection.music_and_audio => [
            const Color.fromARGB(255, 119, 10, 43).value,
            const Color.fromARGB(157, 233, 0, 58).value
          ],
        SnapSection.news_and_weather => [
            const Color.fromARGB(255, 165, 115, 44).value,
            const Color.fromARGB(255, 255, 219, 101).value
          ],
        SnapSection.personalisation => [
            const Color.fromARGB(255, 35, 12, 139).value,
            const Color.fromARGB(255, 25, 173, 166).value
          ],
        SnapSection.photo_and_video => [
            const Color.fromARGB(255, 71, 71, 71).value,
            const Color.fromARGB(255, 133, 133, 133).value
          ],
        SnapSection.productivity => [
            const Color.fromARGB(255, 8, 36, 53).value,
            const Color.fromARGB(255, 41, 112, 104).value
          ],
        SnapSection.science => [
            const Color.fromARGB(255, 71, 71, 71).value,
            YaruColors.orange.value
          ],
        SnapSection.security => [
            const Color.fromARGB(255, 16, 40, 49).value,
            const Color.fromARGB(255, 19, 131, 112).value
          ],
        SnapSection.server_and_cloud => [
            const Color.fromARGB(255, 71, 28, 10).value,
            YaruColors.orange.value
          ],
        SnapSection.social => [
            const Color.fromARGB(255, 11, 73, 59).value,
            const Color.fromARGB(255, 15, 122, 87).value
          ],
        SnapSection.utilities => [
            const Color.fromARGB(136, 82, 74, 40).value,
            const Color.fromARGB(155, 233, 203, 34).value
          ],
        SnapSection.all => [
            const Color.fromARGB(255, 112, 0, 69).value,
            const Color.fromARGB(255, 233, 84, 32).value
          ]
      };

  IconData getIcon(bool selected) {
    switch (this) {
      case SnapSection.all:
        return selected ? YaruIcons.compass_filled : YaruIcons.compass;
      case SnapSection.development:
        return YaruIcons.wrench;
      case SnapSection.games:
        return selected ? YaruIcons.games_filled : YaruIcons.games;
      case SnapSection.art_and_design:
        return selected
            ? YaruIcons.rule_and_pen_filled
            : YaruIcons.rule_and_pen;
      case SnapSection.devices_and_iot:
        return selected ? YaruIcons.chip_filled : YaruIcons.chip;
      case SnapSection.server_and_cloud:
        return selected ? YaruIcons.cloud_filled : YaruIcons.cloud;
      case SnapSection.productivity:
        return selected ? YaruIcons.send_filled : YaruIcons.send;
      default:
        return selected ? YaruIcons.compass_filled : YaruIcons.compass;
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
  SnapSection.all: YaruIcons.application
};
