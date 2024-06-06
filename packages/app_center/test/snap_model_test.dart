import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/snapd_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

const localSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: SnapPublisher(displayName: 'testPublisher'),
  version: '2.0.0',
  website: 'https://example.com',
  confinement: SnapConfinement.classic,
  license: 'MIT',
  description: 'this is the **description**',
  trackingChannel: 'latest/edge',
  channel: 'latest/edge',
);

final storeSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: const SnapPublisher(displayName: 'testPublisher'),
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
  group('init', () {
    const snapName = 'testsnap';

    test('local + store', () async {
      final container = createContainer();
      createMockSnapdService(localSnap: localSnap, storeSnap: storeSnap);
      await container.read(storeSnapProvider(snapName).future);
      final subscription =
          container.listen(snapPackageProvider(snapName), (_, __) {});
      await container.read(snapPackageProvider(snapName).future);
      final snapData = subscription.read().valueOrNull;

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
      createMockSnapdService(storeSnap: storeSnap);
      final subscription =
          container.listen(snapPackageProvider(snapName), (_, __) {});
      await container.read(snapPackageProvider(snapName).future);
      final snapData = subscription.read().valueOrNull;

      expect(snapData?.storeSnap, equals(storeSnap));
      expect(snapData?.localSnap, isNull);
      expect(snapData?.selectedChannel, equals('latest/stable'));
      expect(snapData?.name, equals(snapName));
    });

    test('local only', () async {
      final container = createContainer();
      createMockSnapdService(localSnap: localSnap);
      final subscription =
          container.listen(snapPackageProvider(snapName), (_, __) {});
      await container.read(snapPackageProvider(snapName).future);
      final snapData = subscription.read().valueOrNull;

      expect(snapData?.storeSnap, isNull);
      expect(snapData?.localSnap, localSnap);
      expect(snapData?.selectedChannel, isNull);
      expect(snapData?.name, equals(snapName));
    });

    test('get active change', () async {
      final container = createContainer();
      final service = createMockSnapdService(
        localSnap: localSnap,
        changes: [SnapdChange(spawnTime: DateTime(1970), id: 'active change')],
      );
      final subscription =
          container.listen(snapPackageProvider(snapName), (_, __) {});
      await container.read(snapPackageProvider(snapName).future);
      final snapData = subscription.read().valueOrNull;
      expect(snapData?.activeChangeId, equals('active change'));

      // This is called twice since the provider is rebuilt when the store snap
      // is fully loaded.
      verify(
        service.watchChange(
          snapData?.activeChangeId,
          interval: anyNamed('interval'),
        ),
      ).called(2);
    });
  });

  group('install', () {
    test('default channel', () async {
      final container = createContainer();
      final service = createMockSnapdService(storeSnap: storeSnap);
      await container.read(snapPackageProvider('testsnap').future);
      await container.read(snapPackageProvider('testsnap').notifier).install();

      verify(service.install(
        'testsnap',
        channel: 'latest/stable',
      )).called(1);
    });

    test('non-default channel', () async {
      final container = createContainer();
      final service = createMockSnapdService(storeSnap: storeSnap);
      await container.read(snapPackageProvider('testsnap').future);
      await container
          .read(snapPackageProvider('testsnap').notifier)
          .selectChannel('latest/edge');
      await container.read(snapPackageProvider('testsnap').notifier).install();

      verify(service.install(
        'testsnap',
        channel: 'latest/edge',
        classic: true,
      )).called(1);
    });
  });

  group('refresh', () {
    test('update installed snap', () async {
      final container = createContainer();
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      await container.read(storeSnapProvider('testsnap').future);
      await container.read(snapPackageProvider('testsnap').future);
      await container
          .read(snapPackageProvider('testsnap').notifier)
          .selectChannel('latest/edge');
      await container.read(snapPackageProvider('testsnap').notifier).refresh();

      verify(service.refresh(
        'testsnap',
        channel: 'latest/edge',
        classic: true,
      )).called(1);
    });

    test('switch channel', () async {
      final container = createContainer();
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      await container.read(storeSnapProvider('testsnap').future);
      await container.read(snapPackageProvider('testsnap').future);
      await container
          .read(snapPackageProvider('testsnap').notifier)
          .selectChannel('latest/edge');
      await container
          .read(snapPackageProvider('testsnap').notifier)
          .selectChannel('latest/stable');
      await container.read(snapPackageProvider('testsnap').notifier).refresh();

      verify(service.refresh(
        'testsnap',
        channel: 'latest/stable',
      )).called(1);
    });
  });

  test('remove', () async {
    final container = createContainer();
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    await container.read(snapPackageProvider('testsnap').future);
    await container.read(snapPackageProvider('testsnap').notifier).remove();

    verify(service.remove('testsnap')).called(1);
  });

  test('cancel active change', () async {
    final container = createContainer();
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
      changes: [
        SnapdChange(spawnTime: DateTime(1970), ready: true),
      ],
    );

    when(service.install(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    )).thenAnswer((_) async => 'changeId');

    when(service.watchChange('changeId')).thenAnswer(
      (_) => Stream.fromIterable([
        SnapdChange(spawnTime: DateTime(1970), id: 'changeId'),
      ]),
    );

    await container.read(storeSnapProvider('testsnap').future);
    final snapData =
        await container.read(snapPackageProvider('testsnap').future);

    expect(snapData.activeChangeId, isNull);

    unawaited(
      container.read(snapPackageProvider('testsnap').notifier).install(),
    );
    // To make sure that the install starts, but we can't wait for it since it
    // needs to have time to be cancelled.
    await Future.delayed(Duration.zero);
    await container.read(snapPackageProvider('testsnap').notifier).abort();
    verify(service.abortChange('changeId')).called(1);
  });

  test('error state', () async {
    final container = createContainer();
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    when(service.install(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    )).thenThrow(SnapdException(message: 'error message', kind: 'error kind'));

    await container.read(storeSnapProvider('testsnap').future);
    await container.read(snapPackageProvider('testsnap').future);
    await expectLater(
      container.read(snapPackageProvider('testsnap').notifier).install(),
      throwsA(isA<SnapdException>()),
    );
  });

  group('change progress', () {
    final testCases = [
      (
        name: 'no tasks',
        change: SnapdChange(spawnTime: DateTime(1970)),
        expectedProgress: 0.0,
      ),
      (
        name: '60% completed',
        change: SnapdChange(spawnTime: DateTime(1970), tasks: [
          SnapdTask(progress: const SnapdTaskProgress(done: 2, total: 3)),
          SnapdTask(progress: const SnapdTaskProgress(done: 4, total: 7)),
        ]),
        expectedProgress: 0.6,
      ),
    ];
    for (final testCase in testCases) {
      test(
        testCase.name,
        () => expect(
          testCase.change.progress,
          equals(testCase.expectedProgress),
        ),
      );
    }
  });
}
