import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  group('refresh', () {
    test('no updates available', () async {
      registerMockSnapdService();
      final container = createContainer();
      final model = await container.read(updatesModelProvider.future);
      expect(model, isEmpty);
    });

    test('updates available', () async {
      registerMockSnapdService(
        refreshableSnaps: [createSnap(name: 'firefox')],
      );
      final container = createContainer();
      final model = await container.read(updatesModelProvider.future);
      expect(model.single.name, equals('firefox'));
    });
  });

  test('update all', () async {
    final service = registerMockSnapdService(
      refreshableSnaps: [createSnap(name: 'firefox')],
    );
    final container = createContainer();
    await container.read(updatesModelProvider.future);
    await container.read(updatesModelProvider.notifier).updateAll();
    verify(service.refreshMany(const [])).called(1);
  });

  group('error stream', () {
    test('refresh', () async {
      registerMockErrorStreamControllerService();
      final service = registerMockSnapdService();
      final container = createContainer();
      when(service.find(filter: SnapFindFilter.refresh)).thenThrow(
        SnapdException(
          message: 'error while checking for updates',
          kind: 'error kind',
        ),
      );

      container.listen(
        errorStreamProvider,
        (_, __) {
          expectAsync1<void, SnapdException>(
            (e) {
              expect(e.kind, equals('error kind'));
              expect(e.message, equals('error while checking for updates'));
            },
          );
        },
      );
      await container.read(updatesModelProvider.future);
    });

    test('update all', () async {
      registerMockErrorStreamControllerService();
      final service = registerMockSnapdService(
        refreshableSnaps: [createSnap(id: '', name: 'firefox')],
      );
      final container = createContainer();
      when(service.refreshMany(any)).thenThrow(
        SnapdException(
          message: 'error while updating snaps',
          kind: 'error kind',
        ),
      );
      await container.read(updatesModelProvider.future);

      container.listen(
        errorStreamProvider,
        (_, __) {
          expectAsync1<void, SnapdException>(
            (e) {
              expect(e.kind, equals('error kind'));
              expect(e.message, equals('error while updating snaps'));
            },
          );
        },
      );
      await container.read(updatesModelProvider.notifier).updateAll();
    });
  });
}
