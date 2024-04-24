import 'dart:io';

import 'package:meta/meta.dart';

class ConfigService {
  ConfigService({@visibleForTesting Map<String, String>? env})
      : _env = env ?? Platform.environment;
  final Map<String, String> _env;

  String _ratingsServiceUrl = 'localhost';
  int _ratingsServicePort = 8080;
  bool _ratingsServiceUseTls = false;

  void load() {
    _ratingsServiceUrl = _env['RATINGS_SERVICE_URL'] ?? _ratingsServiceUrl;
    _ratingsServicePort =
        int.tryParse(_env['RATINGS_SERVICE_PORT'] ?? '') ?? _ratingsServicePort;
    _ratingsServiceUseTls =
        _env['RATINGS_SERVICE_USE_TLS']?.toLowerCase() == 'true';
  }

  String get ratingServiceUrl => _ratingsServiceUrl;
  int get ratingsServicePort => _ratingsServicePort;
  bool get ratingsServiceUseTls => _ratingsServiceUseTls;
}
