import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:glib/glib.dart';
import 'package:odrs/odrs.dart';

export 'package:odrs/odrs.dart' show OdrsRating;

const _kCachePeriod = Duration(hours: 1);

class OdrsService {
  OdrsService(Uri url, [@visibleForTesting OdrsClient? client])
      : _client = client ?? _createClient(url);

  final OdrsClient _client;

  static OdrsClient _createClient(Uri url) {
    final salt = glib.getProgramName();
    final username = glib.getUserName();
    final machineId = File('/etc/machine-id').readAsStringSync().trim();
    return OdrsClient(
      url: url,
      userHash:
          sha1.convert(utf8.encode('$salt[$username:$machineId]')).toString(),
      distro: glib.getOsInfo(GOsInfoKey.name) ?? 'unknown',
    );
  }

  Stream<Map<String, OdrsRating>> getRatings() async* {
    final file = _ratingCache();
    final exists = await file.exists();
    if (exists) {
      final ratings = await file.readRatings();
      if (ratings != null) yield ratings;
    }
    if (!exists || await file.expired(_kCachePeriod)) {
      try {
        final ratings = await _client.getRatings();
        yield ratings;
        await file.writeRatings(ratings);
      } on OdrsException {
        // ignore
      }
    }
  }

  bool isOwnReview(OdrsReview review) => review.userHash == _client.userHash;

  Stream<List<OdrsReview>> getReviews(String appId, {String? version}) async* {
    final file = _reviewCache(appId, version);
    final exists = await file.exists();
    if (exists) {
      final reviews = await file.readReviews();
      if (reviews != null) yield reviews;
    }
    if (!exists || await file.expired(_kCachePeriod)) {
      try {
        final reviews =
            await _client.getReviews(appId: appId, version: version);
        yield reviews;
        await file.writeReviews(reviews);
      } on OdrsException {
        // ignore
      }
    }
  }

  Future<OdrsError?> submitReview({
    required String appId,
    required int rating,
    String? locale,
    required String version,
    required String userDisplay,
    required String summary,
    required String description,
  }) async {
    try {
      await _client.submitReview(
        appId: appId,
        rating: rating,
        locale: locale,
        version: version,
        userDisplay: userDisplay,
        summary: summary,
        description: description,
      );
      await _reviewCache(appId, version).invalidate();
    } on OdrsException catch (e) {
      debugPrint('ODRS: ${e.message}');
      return e.error;
    }
    return null;
  }

  File _ratingCache() => File(_cachePath('ratings.json'));
  File _reviewCache(String appId, String? version) {
    return File(_cachePath('$appId-$version.json'));
  }

  String _cachePath(String fileName) {
    final cacheDir = glib.getUserCacheDir();
    final programName = glib.getProgramName();
    return '$cacheDir/$programName/odrs/$fileName';
  }

  void close() => _client.close();
}

extension _OdrsCacheFile on File {
  Future<bool> expired(Duration period) {
    return lastModified().then((timestamp) {
      return timestamp.isBefore(DateTime.now().subtract(period));
    });
  }

  Future<void> invalidate() async {
    if (await exists()) {
      await delete();
    }
  }

  Future<Map<String, OdrsRating>?> readRatings() async {
    try {
      final json = await readAsString().then((data) => jsonDecode(data) as Map);
      return json.map((k, v) => MapEntry(k, OdrsRating.fromJson(v)));
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> writeRatings(Map<String, OdrsRating> ratings) async {
    try {
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      await writeAsString(jsonEncode(ratings));
    } on FileSystemException {
      // ignore
    }
  }

  Future<List<OdrsReview>?> readReviews() async {
    try {
      final json =
          await readAsString().then((data) => jsonDecode(data) as List);
      return json.map((json) => OdrsReview.fromJson(json)).toList();
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> writeReviews(List<OdrsReview> reviews) async {
    try {
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      await writeAsString(jsonEncode(reviews));
    } on FileSystemException {
      // ignore
    }
  }
}
