import 'package:app_center/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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

  test('update all', () async {
    final service =
        createMockSnapdService(refreshableSnaps: [const Snap(name: 'firefox')]);
    final model = UpdatesModel(service);
    await model.refresh();
    await model.updateAll();
    verify(service.refreshMany(const ['firefox'])).called(1);
  });

  test('error stream', () async {
    final service =
        createMockSnapdService(refreshableSnaps: [const Snap(name: 'firefox')]);
    final model = UpdatesModel(service);
    when(service.refreshMany(any)).thenThrow(
        SnapdException(message: 'error message', kind: 'error kind'));

    model.errorStream.listen(
      expectAsync1<void, SnapdException>(
        (e) {
          expect(e.kind, equals('error kind'));
          expect(e.message, equals('error message'));
        },
      ),
    );
    await model.refresh();
    await model.updateAll();
  });
}
