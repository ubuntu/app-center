import 'dart:io';
import 'package:meta/meta.dart';

const String url = 'RATINGS_SERVICE_URL';
const int port = 443;

class ConfigService {
  String _ratingsServiceUrl = 'localhost';
  int _ratingsServicePort = 8080;

  @visibleForTesting
  Map<String, String>? testEnvironment;

  void load() {
    final env = testEnvironment ?? Platform.environment;

    _ratingsServiceUrl = env[url] ?? _ratingsServiceUrl;

    if (env.containsKey(url)) {
      _ratingsServicePort = port;
    }
  }

  String get ratingServiceUrl => _ratingsServiceUrl;
  int get ratingsServicePort => _ratingsServicePort;
}
