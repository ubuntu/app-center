import 'package:app_store/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  group('refresh', () {
    test('no updates available', () async {
      final service = createMockSnapdService();
      final model = UpdatesModel(service);
      await model.refresh();
      expect(model.refreshableSnapNames, isEmpty);
    });
    test('updates available', () async {
      final service = createMockSnapdService(
          refreshableSnaps: [const Snap(name: 'firefox')]);
      final model = UpdatesModel(service);
      await model.refresh();
      expect(model.refreshableSnapNames.single, equals('firefox'));
    });
  });
}
