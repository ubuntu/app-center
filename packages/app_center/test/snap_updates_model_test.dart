import 'dart:async';

import 'package:app_center/error/error.dart';
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
    verify(service.refreshMany([])).called(1);
  });

  test('cancel update all aborts the change it started', () async {
    final testSnap = refreshableSnaps.first;
    final service = registerMockSnapdService(
      localSnap: testSnap,
      storeSnap: testSnap,
      refreshableSnaps: refreshableSnaps,
      installedSnaps: refreshableSnaps,
    );
    // Hold the change open so that there is something to cancel.
    final change = Completer<void>();
    when(service.waitChange(any)).thenAnswer((_) => change.future);

    final container = createContainer();
    await container.read(snapUpdatesModelProvider.future);
    final refreshing = container
        .read(snapUpdatesModelProvider.notifier)
        .refreshAll();
    await pumpEventQueue();

    await container.read(snapUpdatesModelProvider.notifier).cancelRefreshAll();

    verify(service.abortChange('id')).called(1);

    change.complete();
    await refreshing;
  });

  test('update all exposes the change and the snaps snapd put in it', () async {
    final testSnap = refreshableSnaps.first;
    final service = registerMockSnapdService(
      localSnap: testSnap,
      storeSnap: testSnap,
      refreshableSnaps: refreshableSnaps,
      installedSnaps: refreshableSnaps,
    );
    when(service.getChange('id')).thenAnswer(
      (_) async => SnapdChange(id: 'id', snapNames: ['testsnap3']),
    );
    final change = Completer<void>();
    when(service.waitChange(any)).thenAnswer((_) => change.future);

    final container = createContainer();
    await container.read(snapUpdatesModelProvider.future);
    final refreshing = container
        .read(snapUpdatesModelProvider.notifier)
        .refreshAll();
    await pumpEventQueue();

    final running = container.read(currentlyRefreshAllSnapsProvider);
    expect(running.changeId, equals('id'));
    expect(running.snapNames, equals(['testsnap3']));

    change.complete();
    await refreshing;

    final done = container.read(currentlyRefreshAllSnapsProvider);
    expect(done.changeId, isNull);
    expect(done.snapNames, isEmpty);
  });

  test(
    'update all falls back to the store list when snapd names no snaps',
    () async {
      final testSnap = refreshableSnaps.first;
      final service = registerMockSnapdService(
        localSnap: testSnap,
        storeSnap: testSnap,
        refreshableSnaps: refreshableSnaps,
        installedSnaps: refreshableSnaps,
      );
      // getChange is async, so a failure arrives in the future rather than as a
      // synchronous throw.
      when(
        service.getChange('id'),
      ).thenAnswer((_) async => throw SnapdException(message: 'gone'));
      final change = Completer<void>();
      when(service.waitChange(any)).thenAnswer((_) => change.future);

      final container = createContainer();
      await container.read(snapUpdatesModelProvider.future);
      final refreshing = container
          .read(snapUpdatesModelProvider.notifier)
          .refreshAll();
      await pumpEventQueue();

      final running = container.read(currentlyRefreshAllSnapsProvider);
      expect(running.changeId, equals('id'));
      expect(running.snapNames, equals(['testsnap3']));

      change.complete();
      await refreshing;
    },
  );

  test('update all reports the snaps that failed inside the change', () async {
    // ignore: close_sinks
    final errorStream = registerMockErrorStreamControllerService();
    final testSnap = refreshableSnaps.first;
    final service = registerMockSnapdService(
      localSnap: testSnap,
      storeSnap: testSnap,
      refreshableSnaps: refreshableSnaps,
      installedSnaps: refreshableSnaps,
    );
    // The request succeeds and the change runs. Two of its snaps fail inside
    // it, which only shows up in the finished change.
    when(service.getChange('id')).thenAnswer(
      (_) async => SnapdChange(
        id: 'id',
        ready: true,
        status: 'Error',
        snapNames: ['one', 'two', 'three'],
        err:
            'cannot perform the following tasks:\n'
            '- Download snap "one" (12) from channel "latest/stable" (boom)\n'
            '- Run pre-refresh hook of "three" snap if present (exit status 1)',
      ),
    );

    final container = createContainer();
    await container.read(snapUpdatesModelProvider.future);
    await container.read(snapUpdatesModelProvider.notifier).refreshAll();

    final reported =
        verify(errorStream.add(captureAny)).captured.single
            as ConsolidatedSnapdException;
    expect(reported.errors.keys, unorderedEquals(['one', 'three']));
  });

  Future<Object> reportedErrorFor(String err) async {
    // ignore: close_sinks
    final errorStream = registerMockErrorStreamControllerService();
    final testSnap = refreshableSnaps.first;
    final service = registerMockSnapdService(
      localSnap: testSnap,
      storeSnap: testSnap,
      refreshableSnaps: refreshableSnaps,
      installedSnaps: refreshableSnaps,
    );
    when(service.getChange('id')).thenAnswer(
      (_) async => SnapdChange(
        id: 'id',
        ready: true,
        snapNames: ['one'],
        err: err,
      ),
    );

    final container = createContainer();
    await container.read(snapUpdatesModelProvider.future);
    await container.read(snapUpdatesModelProvider.notifier).refreshAll();

    return verify(errorStream.add(captureAny)).captured.single as Object;
  }

  test('update all reports a failing snap that is not in snap-names', () async {
    final reported = await reportedErrorFor(
      'cannot perform the following tasks:\n'
      '- Download snap "one" (12) from channel "latest/stable" (boom)\n'
      '- Mount snap "core24" (900) (no space left)',
    );

    expect(
      (reported as ConsolidatedSnapdException).errors.keys,
      unorderedEquals(['one', 'core24']),
    );
  });

  test('update all shows the whole error when a task names no snap', () async {
    const err =
        'cannot perform the following tasks:\n'
        '- Download snap "one" (12) from channel "latest/stable" (boom)\n'
        '- Something went wrong (no snap here)';
    final reported = await reportedErrorFor(err);

    expect(reported, isNot(isA<ConsolidatedSnapdException>()));
    expect((reported as SnapdException).message, equals(err));
  });

  test('update all does not report an aborted change as a failure', () async {
    // ignore: close_sinks
    final errorStream = registerMockErrorStreamControllerService();
    final testSnap = refreshableSnaps.first;
    final service = registerMockSnapdService(
      localSnap: testSnap,
      storeSnap: testSnap,
      refreshableSnaps: refreshableSnaps,
      installedSnaps: refreshableSnaps,
    );
    when(service.getChange('id')).thenAnswer(
      (_) async => SnapdChange(
        id: 'id',
        ready: true,
        snapNames: ['testsnap3'],
        err: 'cannot perform the following tasks:\n- Download snap "testsnap3"',
      ),
    );
    final change = Completer<void>();
    when(service.waitChange(any)).thenAnswer((_) => change.future);

    final container = createContainer();
    await container.read(snapUpdatesModelProvider.future);
    final refreshing = container
        .read(snapUpdatesModelProvider.notifier)
        .refreshAll();
    await pumpEventQueue();

    await container.read(snapUpdatesModelProvider.notifier).cancelRefreshAll();
    change.complete();
    await refreshing;

    verifyNever(errorStream.add(any));
  });

  test('a failed cancel of update all can be retried', () async {
    registerMockErrorStreamControllerService();
    final testSnap = refreshableSnaps.first;
    final service = registerMockSnapdService(
      localSnap: testSnap,
      storeSnap: testSnap,
      refreshableSnaps: refreshableSnaps,
      installedSnaps: refreshableSnaps,
    );
    final change = Completer<void>();
    when(service.waitChange(any)).thenAnswer((_) => change.future);
    when(service.abortChange(any)).thenThrow(SnapdException(message: 'busy'));

    final container = createContainer();
    await container.read(snapUpdatesModelProvider.future);
    final refreshing = container
        .read(snapUpdatesModelProvider.notifier)
        .refreshAll();
    await pumpEventQueue();

    final model = container.read(snapUpdatesModelProvider.notifier);
    await model.cancelRefreshAll();
    expect(container.read(currentlyRefreshAllSnapsProvider).changeId, 'id');
    await model.cancelRefreshAll();
    verify(service.abortChange('id')).called(2);

    change.complete();
    await refreshing;
  });

  group('localVersion', () {
    test('returns installed version when snap is installed', () async {
      final localSnap = createSnap(name: 'testsnap', version: '1.0.0');
      registerMockSnapdService(installedSnaps: [localSnap]);
      final container = createContainer();

      final version = await container.read(
        localVersionProvider('testsnap').future,
      );
      expect(version, equals('1.0.0'));
    });

    test('returns null when snap is not installed', () async {
      registerMockSnapdService(installedSnaps: []);
      final container = createContainer();

      final version = await container.read(
        localVersionProvider('nonexistent').future,
      );
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

      final snapListState = await container.read(
        snapUpdatesModelProvider.future,
      );
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
