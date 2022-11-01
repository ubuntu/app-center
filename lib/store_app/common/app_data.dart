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

class AppData {
  final String title;
  final String summary;
  final bool strict;
  final String confinementName;
  final String version;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final bool verified;
  final String publisherName;
  final String website;
  final List<String> screenShotUrls;
  final String description;
  final bool? versionChanged;
  final double? rating;
  final List<AppReview>? userReviews;

  AppData({
    required this.title,
    required this.summary,
    required this.strict,
    required this.confinementName,
    required this.version,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.verified,
    required this.publisherName,
    required this.website,
    required this.screenShotUrls,
    required this.description,
    this.versionChanged,
    this.rating,
    this.userReviews,
  });
}

class AppReview {
  final double? rating;
  final String? review;
  final DateTime? dateTime;
  final String? username;

  AppReview({
    this.rating,
    this.review,
    this.dateTime,
    this.username,
  });
}
