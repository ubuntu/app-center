import 'package:app_center/manage/snap_updates_model.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snap_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  final refreshableSnaps = [
    createSnap(
      name: 'testsnap3',
      title: 'Snap with an update',
      version: '2.0',
      channel: 'latest/stable',
      channels: {
        'latest/stable': SnapChannel(
          confinement: SnapConfinement.strict,
          size: 1337,
          releasedAt: DateTime(1970),
          version: '1.0',
        ),
        'latest/edge': SnapChannel(
          confinement: SnapConfinement.classic,
          size: 31337,
          releasedAt: DateTime(1970, 1, 2),
          version: '2.0',
        ),
      },
    ),
  ];

  group('refresh', () {
    test('no updates available', () async {
      registerMockSnapdService();
      final container = createContainer();
      final model = await container.read(snapUpdatesModelProvider.future);
      expect(model.isEmpty, isTrue);
    });

    test('updates available', () async {
      registerMockSnapdService(
        refreshableSnaps: [createSnap(name: 'firefox')],
      );
      final container = createContainer();
      final model = await container.read(snapUpdatesModelProvider.future);
      expect(model.single.name, equals('firefox'));
    });
  });

  test('update all', () async {
    final testSnap = refreshableSnaps.first;
    final service = registerMockSnapdService(
      localSnap: testSnap,
      storeSnap: testSnap,
      refreshableSnaps: refreshableSnaps,
      installedSnaps: refreshableSnaps,
    );
    final container = createContainer();
    await container.read(snapModelProvider('testsnap3').future);
    await container.read(snapUpdatesModelProvider.future);
    await container.read(snapUpdatesModelProvider.notifier).refreshAll();
    verify(service.refresh('testsnap3', channel: anyNamed('channel')))
        .called(1);
  });

  group('localVersion', () {
    test('returns installed version when snap is installed', () async {
      final localSnap = createSnap(name: 'testsnap', version: '1.0.0');
      registerMockSnapdService(installedSnaps: [localSnap]);
      final container = createContainer();

      final version =
          await container.read(localVersionProvider('testsnap').future);
      expect(version, equals('1.0.0'));
    });

    test('returns null when snap is not installed', () async {
      registerMockSnapdService(installedSnaps: []);
      final container = createContainer();

      final version =
          await container.read(localVersionProvider('nonexistent').future);
      expect(version, isNull);
    });
  });

  group('updateVersion', () {
    test('returns update version when update is available', () async {
      final updateSnap = createSnap(name: 'testsnap', version: '2.0.0');
      registerMockSnapdService(refreshableSnaps: [updateSnap]);
      final container = createContainer();

      await container.read(snapUpdatesModelProvider.future);

      final version = container.read(updateVersionProvider('testsnap'));
      expect(version, equals('2.0.0'));
    });

    test('returns null when no update is available', () async {
      registerMockSnapdService();
      final container = createContainer();

      await container.read(snapUpdatesModelProvider.future);

      final version = container.read(updateVersionProvider('testsnap'));
      expect(version, isNull);
    });
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

      expect(container.read(snapUpdatesModelProvider.future), throwsException);
    });

    test('refresh no internet', () async {
      registerMockErrorStreamControllerService();
      final service = registerMockSnapdService();
      final container = createContainer();
      when(service.find(filter: SnapFindFilter.refresh)).thenThrow(
        SnapdException(message: ''),
      );

      final snapListState =
          await container.read(snapUpdatesModelProvider.future);
      expect(snapListState.hasInternet, isFalse);
    });

    test('update all', () async {
      registerMockErrorStreamControllerService();
      final testSnap = refreshableSnaps.first;
      final service = registerMockSnapdService(
        localSnap: testSnap,
        storeSnap: testSnap,
        refreshableSnaps: refreshableSnaps,
        installedSnaps: refreshableSnaps,
      );
      final container = createContainer();
      await container.read(snapModelProvider('testsnap3').future);
      when(service.refreshMany(any)).thenThrow(
        SnapdException(
          message: 'error while updating snaps',
          kind: 'error kind',
        ),
      );
      await container.read(snapUpdatesModelProvider.future);

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
      await container.read(snapUpdatesModelProvider.notifier).refreshAll();
    });
  });
}
