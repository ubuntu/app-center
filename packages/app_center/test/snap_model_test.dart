import 'dart:async';

import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

final localSnap = createSnap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: const SnapPublisher(id: '', displayName: 'testPublisher'),
  version: '2.0.0',
  website: 'https://example.com',
  confinement: SnapConfinement.classic,
  license: 'MIT',
  description: 'this is the **description**',
  trackingChannel: 'latest/edge',
  channel: 'latest/edge',
);

final storeSnap = createSnap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: const SnapPublisher(id: '', displayName: 'testPublisher'),
  version: '1.0.0',
  website: 'https://example.com',
  confinement: SnapConfinement.strict,
  license: 'MIT',
  description: 'this is the **description**',
  downloadSize: 1337,
  channels: {
    'latest/stable': SnapChannel(
      confinement: SnapConfinement.strict,
      size: 1337,
      releasedAt: DateTime(1970),
      version: '1.0.0',
    ),
    'latest/edge': SnapChannel(
      confinement: SnapConfinement.classic,
      size: 31337,
      releasedAt: DateTime(1970, 1, 2),
      version: '2.0.0',
    ),
  },
);

void main() {
  tearDown(resetAllServices);

  group('init', () {
    const snapName = 'testsnap';

    test('local + store', () async {
      final container = createContainer();
      registerMockSnapdService(localSnap: localSnap, storeSnap: storeSnap);
      final subscription = container.listen(
        snapModelProvider(snapName),
        (_, __) {},
      );
      await container.read(snapModelProvider(snapName).future);
      final snapData = subscription.read().value;

      expect(snapData?.name, equals(snapName));
      expect(snapData?.localSnap, isNotNull);
      expect(snapData?.storeSnap, isNotNull);
      expect(snapData?.localSnap?.version, equals('2.0.0'));
      expect(snapData?.storeSnap?.version, equals('1.0.0'));
      expect(snapData?.localSnap, equals(localSnap));
      expect(snapData?.storeSnap, equals(storeSnap));
      expect(snapData?.selectedChannel, equals('latest/edge'));
    });

    test('store only', () async {
      final container = createContainer();
      registerMockSnapdService(storeSnap: storeSnap);
      final snapData = await container.read(snapModelProvider(snapName).future);

      expect(snapData.storeSnap, equals(storeSnap));
      expect(snapData.localSnap, isNull);
      expect(snapData.selectedChannel, equals('latest/stable'));
      expect(snapData.name, equals(snapName));
    });

    test('store with preferred initial channel', () async {
      final container = createContainer();
      registerMockSnapdService(storeSnap: storeSnap);
      container.read(snapInitialChannelProvider(snapName).notifier).state =
          'latest/edge';
      final snapData = await container.read(snapModelProvider(snapName).future);

      expect(snapData.storeSnap, equals(storeSnap));
      expect(snapData.localSnap, isNull);
      expect(snapData.selectedChannel, equals('latest/edge'));
      expect(snapData.name, equals(snapName));
    });

    test('local only', () async {
      final container = createContainer();
      registerMockSnapdService(localSnap: localSnap);
      final subscription = container.listen(
        snapModelProvider(snapName),
        (_, __) {},
      );
      await container.read(snapModelProvider(snapName).future);
      final snapData = subscription.read().value;

      expect(snapData?.storeSnap, isNull);
      expect(snapData?.localSnap, localSnap);
      expect(snapData?.selectedChannel, isNull);
      expect(snapData?.name, equals(snapName));
    });

    test('get active change', () async {
      final container = createContainer();
      final service = registerMockSnapdService(
        localSnap: localSnap,
        changes: [SnapdChange(spawnTime: DateTime(1970), id: 'active change')],
      );
      final subscription = container.listen(
        snapModelProvider(snapName),
        (_, __) {},
      );
      await container.read(snapModelProvider(snapName).future);
      final snapData = subscription.read().value;
      expect(snapData?.activeChangeId, equals('active change'));

      verify(
        service.watchChange(
          snapData?.activeChangeId,
          interval: anyNamed('interval'),
        ),
      ).called(1);
    });
  });

  group('install', () {
    test('default channel', () async {
      final container = createContainer();
      final service = registerMockSnapdService(storeSnap: storeSnap);
      final subscription = container.listen(
        snapModelProvider('testsnap').future,
        (_, __) {},
      );
      await subscription.read();
      await container.read(snapModelProvider('testsnap').notifier).install();

      verify(
        service.install(
          'testsnap',
          channel: 'latest/stable',
        ),
      ).called(1);
    });

    test('non-default channel', () async {
      final container = createContainer();
      final service = registerMockSnapdService(storeSnap: storeSnap);
      await container.read(snapModelProvider('testsnap').future);
      await container
          .read(snapModelProvider('testsnap').notifier)
          .selectChannel('latest/edge');
      await container.read(snapModelProvider('testsnap').notifier).install();

      verify(
        service.install(
          'testsnap',
          channel: 'latest/edge',
          classic: true,
        ),
      ).called(1);
    });

    test('explicit channel ignores the selected channel', () async {
      final container = createContainer();
      final service = registerMockSnapdService(storeSnap: storeSnap);
      await container.read(snapModelProvider('testsnap').future);
      await container
          .read(snapModelProvider('testsnap').notifier)
          .install(channel: 'latest/edge');

      verify(
        service.install(
          'testsnap',
          channel: 'latest/edge',
          classic: true,
        ),
      ).called(1);
    });
  });

  group('refresh', () {
    test('update installed snap', () async {
      final container = createContainer();
      final service = registerMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      await container.read(snapModelProvider('testsnap').future);
      await container
          .read(snapModelProvider('testsnap').notifier)
          .selectChannel('latest/edge');
      await container.read(snapModelProvider('testsnap').notifier).refresh();

      verify(
        service.refresh(
          'testsnap',
          channel: 'latest/edge',
          classic: true,
        ),
      ).called(1);
    });

    test('switch channel', () async {
      final container = createContainer();
      final service = registerMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      await container.read(snapModelProvider('testsnap').future);
      await container
          .read(snapModelProvider('testsnap').notifier)
          .selectChannel('latest/edge');
      await container
          .read(snapModelProvider('testsnap').notifier)
          .selectChannel('latest/stable');
      await container.read(snapModelProvider('testsnap').notifier).refresh();

      verify(
        service.refresh(
          'testsnap',
          channel: 'latest/stable',
        ),
      ).called(1);
    });

    test('explicit channel ignores the selected channel', () async {
      final container = createContainer();
      final service = registerMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      await container.read(snapModelProvider('testsnap').future);
      await container
          .read(snapModelProvider('testsnap').notifier)
          .selectChannel('latest/stable');
      await container
          .read(snapModelProvider('testsnap').notifier)
          .refresh(channel: 'latest/edge');

      verify(
        service.refresh(
          'testsnap',
          channel: 'latest/edge',
          classic: true,
        ),
      ).called(1);
    });
  });

  test('remove', () async {
    final container = createContainer();
    final service = registerMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    await container.read(snapModelProvider('testsnap').future);
    await container.read(snapModelProvider('testsnap').notifier).remove();

    verify(service.remove('testsnap')).called(1);
  });

  test('keeps the change active until the refreshed state is ready', () async {
    final container = createContainer();
    final service = registerMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    container.listen(snapModelProvider('testsnap'), (_, __) {});
    await container.read(snapModelProvider('testsnap').future);

    final refreshGetSnap = Completer<Snap>();
    when(service.getSnap(any)).thenAnswer((_) => refreshGetSnap.future);

    await container.read(snapModelProvider('testsnap').notifier).remove();
    // Let the rebuild reach the pending getSnap().
    await Future<void>.delayed(Duration.zero);

    // Stale data must not be shown without an active change.
    final current = container.read(snapModelProvider('testsnap')).value!;
    expect(current.localSnap, isNotNull);
    expect(current.activeChangeId, equals('id'));

    refreshGetSnap.completeError(
      SnapdException(message: 'snap not installed', kind: 'snap-not-found'),
    );
    final refreshed = await container.read(
      snapModelProvider('testsnap').future,
    );

    expect(refreshed.localSnap, isNull);
    expect(refreshed.activeChangeId, isNull);
  });

  test('cancel active change', () async {
    final container = createContainer();
    final service = registerMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
      changes: [
        SnapdChange(id: '', spawnTime: DateTime(1970), ready: true),
      ],
    );

    when(
      service.install(
        any,
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    ).thenAnswer((_) async => 'changeId');

    when(service.watchChange('changeId')).thenAnswer(
      (_) => Stream.fromIterable([
        SnapdChange(spawnTime: DateTime(1970), id: 'changeId'),
      ]),
    );

    final snapData = await container.read(snapModelProvider('testsnap').future);
    expect(snapData.activeChangeId, isNull);

    unawaited(
      container.read(snapModelProvider('testsnap').notifier).install(),
    );
    // To make sure that the install starts, but we can't wait for it since it
    // needs to have time to be cancelled.
    await Future.delayed(Duration.zero);
    await container.read(snapModelProvider('testsnap').notifier).cancel();
    verify(service.abortChange('changeId')).called(1);
  });

  test('error state', () async {
    final container = createContainer();
    final service = registerMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    when(
      service.install(
        any,
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    ).thenThrow(SnapdException(message: 'error message', kind: 'error kind'));

    await container.read(snapModelProvider('testsnap').future);
    await expectLater(
      container.read(snapModelProvider('testsnap').notifier).install(),
      throwsA(isA<SnapdException>()),
    );
  });

  group('change progress', () {
    SnapdTask task(
      String kind,
      String status, {
      int done = 0,
      int total = 0,
    }) => SnapdTask(
      id: '',
      kind: kind,
      status: status,
      progress: SnapdTaskProgress(done: done, total: total),
    );
    SnapdChange change(List<SnapdTask> tasks) =>
        SnapdChange(id: '', spawnTime: DateTime(1970), tasks: tasks);

    test('no tasks', () => expect(change([]).progress, 0.0));

    test('ignores byte units of a download when weighing other tasks', () {
      final progress = change([
        task('prerequisites', 'Done', done: 1, total: 1),
        task('download-snap', 'Doing', total: 100000000),
        task('mount-snap', 'Do', total: 1),
        task('link-snap', 'Do', total: 1),
      ]).progress;
      // No jump back to zero when the download total replaces 0/1.
      expect(progress, closeTo(0.1, 1e-9));
    });

    test('is not complete when only the download is', () {
      final progress = change([
        task('download-snap', 'Done', done: 100, total: 100),
        task('mount-snap', 'Doing', done: 1, total: 1),
        task('link-snap', 'Do', total: 1),
      ]).progress;
      expect(progress, closeTo(0.7, 1e-9));
    });

    test('weighs downloads equally regardless of their size', () {
      final progress = change([
        task('download-snap', 'Done', done: 5, total: 5),
        task('download-snap', 'Doing', done: 50, total: 100),
      ]).progress;
      expect(progress, closeTo(0.75, 1e-9));
    });

    test('uses the full range without downloads', () {
      final progress = change([
        task('stop-snap-services', 'Done', done: 1, total: 1),
        task('unlink-snap', 'Doing', done: 1, total: 1),
        task('discard-snap', 'Do', total: 1),
        task('clear-snap', 'Do', total: 1),
      ]).progress;
      expect(progress, closeTo(0.25, 1e-9));
    });

    test('is complete when all tasks are done', () {
      final progress = change([
        task('download-snap', 'Done', done: 100, total: 100),
        task('link-snap', 'Done', done: 1, total: 1),
      ]).progress;
      expect(progress, 1.0);
    });
  });

  group('change progress provider', () {
    SnapdChange change(List<SnapdTask> tasks) =>
        SnapdChange(id: 'c', spawnTime: DateTime(1970), tasks: tasks);
    const done = SnapdTask(
      id: '',
      kind: 'link-snap',
      status: 'Done',
      progress: SnapdTaskProgress(done: 1, total: 1),
    );
    const queued = SnapdTask(
      id: '',
      kind: 'link-snap',
      status: 'Do',
      progress: SnapdTaskProgress(total: 1),
    );

    late StreamController<SnapdChange> changes;
    late ProviderContainer container;
    late List<double?> values;

    setUp(() {
      changes = StreamController<SnapdChange>();
      addTearDown(changes.close);
      final snapd = registerMockSnapdService();
      when(snapd.watchChange('c')).thenAnswer((_) => changes.stream);
      container = createContainer();
      values = [];
      container.listen(
        snapChangeProgressProvider('c'),
        (_, next) => values.add(next),
        fireImmediately: true,
      );
    });

    Future<void> emit(List<SnapdTask> tasks) async {
      changes.add(change(tasks));
      await Future<void>.delayed(Duration.zero);
    }

    test('is null without a change id', () {
      expect(container.read(snapChangeProgressProvider(null)), isNull);
    });

    test('is null until the change has tasks', () async {
      await emit([]);
      expect(values, [null]);
    });

    test('never goes backwards when tasks are added', () async {
      await emit([done, queued]);
      await emit([done, queued, queued, queued]);
      await emit([done, done, queued, queued]);
      await emit([done, done, done, queued]);

      expect(values, [null, 0.5, 0.75]);
    });
  });

  group('revert', () {
    const snapName = 'testsnap';

    test('revert installed snap', () async {
      final container = createContainer();
      final oldVersion = '1.0.0';
      final newVersion = '2.0.0';
      final oldRevision = 100;
      final newRevision = 200;

      // Create snap with old version (simulating after revert)
      final revertedSnap = createSnap(
        name: snapName,
        version: oldVersion,
        revision: oldRevision,
      );

      final service = registerMockSnapdService(
        localSnap: createSnap(
          name: snapName,
          version: newVersion,
          revision: newRevision,
        ),
      );

      // Mock the revert to return the old version
      when(service.getSnap(snapName)).thenAnswer((_) async => revertedSnap);

      final model = container.read(snapModelProvider(snapName).notifier);
      await container.read(snapModelProvider(snapName).future);

      await model.revert();

      verify(service.revert(snapName)).called(1);

      // Verify the snap was refreshed after revert
      final snapData = await container.read(snapModelProvider(snapName).future);
      expect(snapData.localSnap?.version, equals(oldVersion));
      expect(snapData.localSnap?.revision, equals(oldRevision));
    });

    test('cannot revert uninstalled snap', () async {
      final container = createContainer();
      registerMockSnapdService(storeSnap: storeSnap);
      final model = container.read(snapModelProvider(snapName).notifier);
      await container.read(snapModelProvider(snapName).future);

      expect(
        model.revert,
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
