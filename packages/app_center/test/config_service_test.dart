import 'package:app_center/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default values', () {
    final configService = ConfigService();
    configService.load();
    expect(configService.ratingServiceUrl, equals('localhost'));
    expect(configService.ratingsServicePort, equals(8080));
    expect(configService.ratingsServiceUseTls, isFalse);
  });

  test('custom values', () {
    final configService = ConfigService(
      env: {
        'RATINGS_SERVICE_URL': 'test.url',
        'RATINGS_SERVICE_PORT': '443',
        'RATINGS_SERVICE_USE_TLS': 'true',
      },
    );
    configService.load();
    expect(configService.ratingServiceUrl, equals('test.url'));
    expect(configService.ratingsServicePort, equals(443));
    expect(configService.ratingsServiceUseTls, isTrue);
  });
}
