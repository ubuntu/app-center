import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundles Hebrew font assets for Flutter', () async {
    for (final filename in [
      'NotoSansHebrew-Regular.ttf',
      'NotoSansHebrew-Bold.ttf',
    ]) {
      final bytes = await rootBundle.load('assets/fonts/$filename');
      expect(bytes.lengthInBytes, greaterThan(1000), reason: filename);
    }
  });
}
