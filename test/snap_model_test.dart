import 'dart:async';

import 'package:app_store/snapd.dart';
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
      final updatesModel = createMockUpdatesModel();
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
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
      final updatesModel = createMockUpdatesModel();
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
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
      final updatesModel = createMockUpdatesModel();
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
      await model.init();

      expect(model.state.hasValue, isTrue);
      expect(model.storeSnap, isNull);
      expect(model.localSnap, equals(localSnap));
      expect(model.selectedChannel, isNull);
    });
  });

  group('install', () {
    test('default channel', () async {
      final service = createMockSnapdService(
        storeSnap: storeSnap,
      );
      final updatesModel = createMockUpdatesModel();
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
      await model.init();

      await model.install();

      verify(service.install('testsnap', channel: 'latest/stable')).called(1);
    });
    test('non-default channel', () async {
      final service = createMockSnapdService(
        storeSnap: storeSnap,
      );
      final updatesModel = createMockUpdatesModel();
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
      await model.init();

      model.selectedChannel = 'latest/edge';
      await model.install();

      verify(service.install('testsnap', channel: 'latest/edge')).called(1);
    });
  });

  group('refresh', () {
    test('update installed snap', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      final updatesModel =
          createMockUpdatesModel(refreshableSnapNames: [storeSnap.name]);
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
      await model.init();

      await model.refresh();

      verify(service.refresh('testsnap', channel: 'latest/edge')).called(1);
    });
    test('switch channel', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      final updatesModel = createMockUpdatesModel();
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
      await model.init();

      model.selectedChannel = 'latest/stable';
      await model.refresh();

      verify(service.refresh('testsnap', channel: 'latest/stable')).called(1);
    });
  });

  test('remove', () async {
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    final updatesModel = createMockUpdatesModel();
    final model = SnapModel(
        snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
    await model.init();

    await model.remove();

    verify(service.remove('testsnap')).called(1);
  });

  test('cancel active change', () async {
    final service = createMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    final changeCompleter = Completer();
    final notifyCompleter = Completer();

    when(service.install(any, channel: anyNamed('channel')))
        .thenAnswer((_) async => 'changeId');
    when(service.waitChange('changeId'))
        .thenAnswer((_) async => await changeCompleter.future);
    when(service.abortChange('changeId')).thenAnswer((_) async {
      changeCompleter.complete();
      return SnapdChange(spawnTime: DateTime.now());
    });

    final updatesModel = createMockUpdatesModel();
    final model = SnapModel(
        snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
    await model.init();

    expect(model.activeChangeId, isNull);
    model.addListener(() {
      if (!notifyCompleter.isCompleted) notifyCompleter.complete();
    });
    unawaited(model.install());
    await notifyCompleter.future;
    expect(model.activeChangeId, equals('changeId'));

    await model.cancel();
    verify(service.abortChange('changeId')).called(1);
    expect(model.activeChangeId, isNull);
  });

  group('hasUpdate', () {
    test('update available', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      final updatesModel = createMockUpdatesModel(
          refreshableSnapNames: ['testsnap', 'otherapp']);
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
      await model.init();

      expect(model.hasUpdate, isTrue);
    });

    test('no update available', () async {
      final service = createMockSnapdService(
        localSnap: localSnap,
        storeSnap: storeSnap,
      );
      final updatesModel =
          createMockUpdatesModel(refreshableSnapNames: ['otherapp']);
      final model = SnapModel(
          snapd: service, updatesModel: updatesModel, snapName: 'testsnap');
      await model.init();

      expect(model.hasUpdate, isFalse);
    });
  });
}
