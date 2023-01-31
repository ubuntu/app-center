import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:glib/glib.dart';
import 'package:meta/meta.dart';
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
    final file = File(_cachePath('ratings.json'));
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
}
