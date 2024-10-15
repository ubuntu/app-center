import 'dart:convert';
import 'dart:io';

import 'package:app_center/snapd/snap_category_enum.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart'
    as ratings;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glib/glib.dart';
import 'package:jwt_decode/jwt_decode.dart';

class RatingsService {
  RatingsService(this.client, {@visibleForTesting String? id})
      : _id = id ?? _generateId();

  final ratings.RatingsClient client;
  String? _jwt;
  final String _id;

  static String _generateId() {
    final username = glib.getUserName();
    final machineId = File('/etc/machine-id').readAsStringSync().trim();
    return sha256.convert(utf8.encode('[$username:$machineId]')).toString();
  }

  Future<void> _ensureValidToken() async {
    if (_jwt == null || Jwt.isExpired(_jwt!)) {
      _jwt = await client.authenticate(_id);
    }
  }

  Future<ratings.Rating?> getRating(String snapId) async {
    await _ensureValidToken();
    return client.getRating(snapId, _jwt!);
  }

  Future<List<ratings.ChartData>> getChart(SnapCategoryEnum category) async {
    await _ensureValidToken();

    final categoryToChart = {
      SnapCategoryEnum.artAndDesign: ratings.Category.ART_AND_DESIGN,
      SnapCategoryEnum.booksAndReference: ratings.Category.BOOK_AND_REFERENCE,
      SnapCategoryEnum.development: ratings.Category.DEVELOPMENT,
      SnapCategoryEnum.devicesAndIot: ratings.Category.DEVICES_AND_IOT,
      SnapCategoryEnum.education: ratings.Category.EDUCATION,
      SnapCategoryEnum.entertainment: ratings.Category.ENTERTAINMENT,
      SnapCategoryEnum.featured: ratings.Category.FEATURED,
      SnapCategoryEnum.finance: ratings.Category.FINANCE,
      SnapCategoryEnum.gameContentCreation: ratings.Category.GAMES,
      SnapCategoryEnum.gameDev: ratings.Category.GAMES,
      SnapCategoryEnum.gameEmulators: ratings.Category.GAMES,
      SnapCategoryEnum.gameLaunchers: ratings.Category.GAMES,
      SnapCategoryEnum.games: ratings.Category.GAMES,
      SnapCategoryEnum.gnomeGames: ratings.Category.GAMES,
      SnapCategoryEnum.healthAndFitness: ratings.Category.HEALTH_AND_FITNESS,
      SnapCategoryEnum.kdeGames: ratings.Category.GAMES,
      SnapCategoryEnum.musicAndAudio: ratings.Category.MUSIC_AND_AUDIO,
      SnapCategoryEnum.newsAndWeather: ratings.Category.NEWS_AND_WEATHER,
      SnapCategoryEnum.personalisation: ratings.Category.PERSONALISATION,
      SnapCategoryEnum.photoAndVideo: ratings.Category.PHOTO_AND_VIDEO,
      SnapCategoryEnum.productivity: ratings.Category.PRODUCTIVITY,
      SnapCategoryEnum.science: ratings.Category.SCIENCE,
      SnapCategoryEnum.security: ratings.Category.SECURITY,
      SnapCategoryEnum.serverAndCloud: ratings.Category.SERVER_AND_CLOUD,
      SnapCategoryEnum.social: ratings.Category.SOCIAL,
      // SnapCategoryEnum.ubuntuDesktop: 0, // no valid mapping
      // SnapCategoryEnum.unknown: 0, // no valid mapping
      SnapCategoryEnum.utilities: ratings.Category.UTILITIES,
    };

    return client.getChart(
      ratings.Timeframe.unspecified,
      _jwt!,
      categoryToChart[category],
    );
  }

  Future<void> vote(ratings.Vote vote) async {
    await _ensureValidToken();
    await client.vote(vote.snapId, vote.snapRevision, vote.voteUp, _jwt!);
  }

  Future<void> delete() async {
    await _ensureValidToken();
    await client.delete(_jwt!);
  }

  Future<List<ratings.Vote>> listMyVotes(String snapFilter) async {
    await _ensureValidToken();
    return client.listMyVotes(snapFilter, _jwt!);
  }

  Future<List<ratings.Vote>> getSnapVotes(String snapId) async {
    await _ensureValidToken();
    return client.getSnapVotes(snapId, _jwt!);
  }
}
