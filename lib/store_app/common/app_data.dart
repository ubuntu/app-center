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
  final String name;
  final String summary;
  final bool strict;
  final String confinementName;
  final String version;
  final String license;
  final String? installDate;
  final String? installDateIsoNorm;
  final bool verified;
  final bool starredDeveloper;
  final String? publisherName;
  final String website;
  final List<String> screenShotUrls;
  final String description;
  final bool? versionChanged;
  final double? averageRating;
  final List<AppReview>? userReviews;

  AppData({
    required this.title,
    required this.name,
    required this.summary,
    required this.strict,
    required this.confinementName,
    required this.version,
    required this.license,
    this.installDate,
    this.installDateIsoNorm,
    required this.verified,
    required this.starredDeveloper,
    this.publisherName,
    required this.website,
    required this.screenShotUrls,
    required this.description,
    this.versionChanged,
    this.averageRating,
    this.userReviews,
  });
}

class AppReview {
  final int? id;
  final double? rating;
  final String? review;
  final String? title;
  final DateTime? dateTime;
  final String? username;
  final int? positiveVote;
  final int? negativeVote;

  AppReview({
    this.id,
    this.rating,
    this.review,
    this.title,
    this.dateTime,
    this.username,
    this.positiveVote,
    this.negativeVote,
  });
}
