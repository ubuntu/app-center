import 'package:app_center/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('env vars not set', () {
    final configService = ConfigService();
    configService.testEnvironment = {};
    configService.load();
    expect(configService.ratingServiceUrl, 'localhost');
    expect(configService.ratingsServicePort, 8080);
  });

  test('env vars set', () {
    final configService = ConfigService();
    configService.testEnvironment = {
      'RATINGS_SERVICE_URL': 'test.url',
    };
    configService.load();
    expect(configService.ratingServiceUrl, 'test.url');
    expect(configService.ratingsServicePort, 443);
  });
}
