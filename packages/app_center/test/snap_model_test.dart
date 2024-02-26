import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/multisnap_model.dart';
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
    test('local + store', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      expect(model.state.hasValue, isTrue);
      expect(model.storeSnap, equals(storeSnap));
      expect(model.localSnap, equals(localSnap));
      expect(model.selectedChannel, equals('latest/edge'));
    });

    test('store-only', () async {
      final service = createMockSnapdService(
        storeSnap: storeSnap,
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      expect(model.state.hasValue, isTrue);
      expect(model.storeSnap, equals(storeSnap));
      expect(model.localSnap, isNull);
      expect(model.selectedChannel, equals('latest/stable'));
    });

    test('local-only', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      expect(model.state.hasValue, isTrue);
      expect(model.storeSnap, isNull);
      expect(model.localSnap, equals(localSnap));
      expect(model.selectedChannel, isNull);
    });

    test('get active change', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        changes: [SnapdChange(spawnTime: DateTime(1970), id: 'active change')],
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      verify(service.getChanges(name: localSnap.name)).called(1);
      expect(model.activeChangeId, equals('active change'));
    });
  });

  group('install', () {
    test('default channel', () async {
      final service = createMockSnapdService(
        storeSnap: storeSnap,
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      await model.install();

      verify(service.install(
        'testsnap',
        channel: 'latest/stable',
      )).called(1);
    });
    test('non-default channel', () async {
      final service = createMockSnapdService(
        storeSnap: storeSnap,
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      model.selectedChannel = 'latest/edge';
      await model.install();

      verify(service.install(
        'testsnap',
        channel: 'latest/edge',
        classic: true,
      )).called(1);
    });
  });

  group('refresh', () {
    test('update installed snap', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      await model.refresh();

      verify(service.refresh(
        'testsnap',
        channel: 'latest/edge',
        classic: true,
      )).called(1);
    });
    test('switch channel', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      final model = SnapModel(snapd: service, snapName: 'testsnap');
      await model.init();

      model.selectedChannel = 'latest/stable';
      await model.refresh();

      verify(service.refresh(
        'testsnap',
        channel: 'latest/stable',
      )).called(1);
    });
  });

  test('remove', () async {
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    final model = SnapModel(snapd: service, snapName: 'testsnap');
    await model.init();

    await model.remove();

    verify(service.remove('testsnap')).called(1);
  });

  test('cancel active change', () async {
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    var notifyCompleter = Completer();

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

    final model = SnapModel(snapd: service, snapName: 'testsnap');
    await model.init();

    expect(model.activeChangeId, isNull);
    model.addListener(() {
      if (!notifyCompleter.isCompleted) notifyCompleter.complete();
    });
    unawaited(model.install());
    await notifyCompleter.future;
    expect(model.activeChangeId, equals('changeId'));

    notifyCompleter = Completer();
    model.addListener(expectAsync0(() {
      expect(model.activeChangeId, isNull);
      if (!notifyCompleter.isCompleted) notifyCompleter.complete();
    }));
    await model.cancel();
    verify(service.abortChange('changeId')).called(1);
    await notifyCompleter.future;
  });

  test('error stream', () async {
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    when(service.install(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    )).thenThrow(SnapdException(message: 'error message', kind: 'error kind'));

    final model = SnapModel(snapd: service, snapName: 'testsnap');
    await model.init();

    model.errorStream.listen(
      expectAsync1<void, SnapdException>(
        (e) {
          expect(e.kind, equals('error kind'));
          expect(e.message, equals('error message'));
        },
      ),
    );
    await model.install();
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
  test('install-many', () async {
    final service = createMockSnapdService(
      storeSnap: storeSnap,
    );
    final model =
        MultiSnapModel(snapd: service, category: SnapCategoryEnum.gameDev);
    await model.init();

    await model.installAll();

    verify(service.installMany(List<String>.from(List<String>.generate(
        SnapCategoryEnum.gameDev.featuredSnapNames!.length,
        (index) => 'testsnap')))).called(1);
  });
}
