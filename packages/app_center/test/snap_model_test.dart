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
      final container = ProviderContainer();
      createMockSnapdService(localSnap: localSnap, storeSnap: storeSnap);
      await container.read(storeSnapProvider(snapName).future);
      final snapData = await container.read(snapDataProvider(snapName).future);

      expect(snapData.name, equals(snapName));
      expect(snapData.localSnap, isNotNull);
      expect(snapData.storeSnap, isNotNull);
      expect(snapData.localSnap?.version, equals('2.0.0'));
      expect(snapData.storeSnap?.version, equals('1.0.0'));
      expect(snapData.localSnap, equals(localSnap));
      expect(snapData.storeSnap, equals(storeSnap));
      expect(snapData.selectedChannel, equals('latest/edge'));

      container.dispose();
    });

    test('store only', () async {
      final container = ProviderContainer();
      createMockSnapdService(storeSnap: storeSnap);
      await container.read(storeSnapProvider(snapName).future);
      final snapData = await container.read(snapDataProvider(snapName).future);

      expect(snapData.storeSnap, equals(storeSnap));
      expect(snapData.localSnap, isNull);
      expect(snapData.selectedChannel, equals('latest/stable'));
      expect(snapData.name, equals(snapName));

      container.dispose();
    });

    test('local only', () async {
      final container = ProviderContainer();
      createMockSnapdService(localSnap: localSnap);
      final snapData = await container.read(snapDataProvider(snapName).future);

      expect(snapData.storeSnap, isNull);
      expect(snapData.localSnap, localSnap);
      expect(snapData.selectedChannel, isNull);
      expect(snapData.name, equals(snapName));

      container.dispose();
    });

    test('get active change', () async {
      final container = ProviderContainer(overrides: [
        activeChangeIdProvider.overrideWith((_, __) => 'active change'),
      ]);
      final service = createMockSnapdService(
        localSnap: localSnap,
        changes: [SnapdChange(spawnTime: DateTime(1970), id: 'active change')],
      );
      final snapData = await container.read(snapDataProvider(snapName).future);
      container.read(activeChangeProvider(snapData.activeChangeId));

      expect(snapData.activeChangeId, equals('active change'));
      verify(
        service.watchChange(
          snapData.activeChangeId,
          interval: anyNamed('interval'),
        ),
      ).called(1);

      container.dispose();
    });
  });

  group('install', () {
    test('default channel', () async {
      final container = ProviderContainer();
      final service = createMockSnapdService(storeSnap: storeSnap);
      await container.read(storeSnapProvider('testsnap').future);
      await container.read(snapDataProvider('testsnap').future);
      await container.read(snapInstallProvider('testsnap').future);

      verify(service.install(
        'testsnap',
        channel: 'latest/stable',
      )).called(1);
      container.dispose();
    });

    test('non-default channel', () async {
      final container = ProviderContainer(overrides: [
        selectedChannelProvider.overrideWith((_, __) => 'latest/edge'),
      ]);
      final service = createMockSnapdService(storeSnap: storeSnap);
      await container.read(storeSnapProvider('testsnap').future);
      await container.read(snapDataProvider('testsnap').future);

      await container.read(snapInstallProvider('testsnap').future);

      verify(service.install(
        'testsnap',
        channel: 'latest/edge',
        classic: true,
      )).called(1);
      container.dispose();
    });
  });

  group('refresh', () {
    test('update installed snap', () async {
      final container = ProviderContainer(overrides: [
        selectedChannelProvider.overrideWith((_, __) => 'latest/edge'),
      ]);
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      await container.read(storeSnapProvider('testsnap').future);
      final snapData =
          await container.read(snapDataProvider('testsnap').future);

      await container.read(snapRefreshProvider(snapData).future);

      verify(service.refresh(
        'testsnap',
        channel: 'latest/edge',
        classic: true,
      )).called(1);
      container.dispose();
    });

    test('switch channel', () async {
      final container = ProviderContainer(overrides: [
        selectedChannelProvider.overrideWith((_, __) => 'latest/edge'),
      ]);
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      container.read(selectedChannelProvider('testsnap').notifier).state =
          'latest/stable';
      await container.read(storeSnapProvider('testsnap').future);
      final snapData =
          await container.read(snapDataProvider('testsnap').future);

      await container.read(snapRefreshProvider(snapData).future);

      verify(service.refresh(
        'testsnap',
        channel: 'latest/stable',
      )).called(1);
      container.dispose();
    });
  });

  test('remove', () async {
    final container = ProviderContainer();
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    await container.read(snapRemoveProvider('testsnap').future);

    verify(service.remove('testsnap')).called(1);
    container.dispose();
  });

  test('cancel active change', () async {
    final container = ProviderContainer();
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );

    when(service.install(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    )).thenAnswer((_) async => 'changeId');

    when(service.watchChange('changeId')).thenAnswer(
      (_) => Stream.fromIterable(
        [
          SnapdChange(spawnTime: DateTime(1970)),
          SnapdChange(spawnTime: DateTime(1970), ready: true),
        ],
      ),
    );

    container.read(selectedChannelProvider('testsnap').notifier).state =
        'latest/stable';
    await container.read(storeSnapProvider('testsnap').future);
    final snapData = await container.read(snapDataProvider('testsnap').future);

    expect(snapData.activeChangeId, isNull);
    await container.read(snapInstallProvider('testsnap').future);
    final snapDataWithChangeId =
        await container.read(snapDataProvider('testsnap').future);
    expect(snapDataWithChangeId.activeChangeId, equals('changeId'));

    await container.read(snapAbortProvider('testsnap').future);
    verify(service.abortChange('changeId')).called(1);
  });

  test('error state', () async {
    final container = ProviderContainer();
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    when(service.install(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    )).thenThrow(SnapdException(message: 'error message', kind: 'error kind'));

    await container.read(storeSnapProvider('testSnap').future);
    await container.read(snapDataProvider('testSnap').future);
    await expectLater(
      container.read(snapInstallProvider('testSnap').future),
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
