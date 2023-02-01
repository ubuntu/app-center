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

import 'package:software/app/common/app_format.dart';

class AppData {
  final String title;
  final String name;
  final String summary;
  final bool strict;
  final String confinementName;
  final String version;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final bool verified;
  final bool starredDeveloper;
  final String publisherName;
  final String website;
  final String contact;
  final List<String> screenShotUrls;
  final String description;
  final bool versionChanged;
  final double averageRating;
  final List<AppReview> userReviews;
  final AppFormat appFormat;
  final String appSize;
  final String releasedAt;

  AppData({
    required this.title,
    required this.name,
    required this.summary,
    required this.strict,
    required this.confinementName,
    required this.version,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.verified,
    required this.starredDeveloper,
    required this.publisherName,
    required this.website,
    required this.screenShotUrls,
    required this.description,
    required this.versionChanged,
    required this.averageRating,
    required this.userReviews,
    required this.appFormat,
    required this.appSize,
    required this.releasedAt,
    required this.contact,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppReview &&
        other.id == id &&
        other.rating == rating &&
        other.review == review &&
        other.title == title &&
        other.dateTime == dateTime &&
        other.username == username &&
        other.positiveVote == positiveVote &&
        other.negativeVote == negativeVote;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      rating,
      review,
      title,
      dateTime,
      username,
      positiveVote,
      negativeVote,
    );
  }
}
