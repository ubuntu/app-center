import 'dart:async';

import 'package:app_center/snapd.dart';
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
        classic: false,
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
        classic: false,
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
    final changeCompleter = Completer();
    final notifyCompleter = Completer();

    when(service.install(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    )).thenAnswer((_) async => 'changeId');
    when(service.waitChange('changeId'))
        .thenAnswer((_) async => await changeCompleter.future);
    when(service.abortChange('changeId')).thenAnswer((_) async {
      changeCompleter.complete();
      return SnapdChange(spawnTime: DateTime.now());
    });

    final model = SnapModel(snapd: service, snapName: 'testsnap');
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
}
