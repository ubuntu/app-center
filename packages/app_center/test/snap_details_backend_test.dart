import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/snapd/snap_details_backend.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

final _refProvider = Provider<Ref>((ref) => ref);

final _stable = SnapChannel(
  confinement: SnapConfinement.strict,
  revision: '2',
  size: 50,
  releasedAt: DateTime(2026, 1, 2),
  version: '2.0',
);

final _beta = SnapChannel(
  confinement: SnapConfinement.classic,
  revision: '4',
  releasedAt: DateTime(2026, 1, 3),
  version: '4.0',
);

final _storeSnap = createSnap(
  name: 'testsnap',
  title: 'Test Snap',
  summary: 'summary',
  description: 'the **description**',
  license: 'MIT',
  website: 'https://example.com',
  publisher: const SnapPublisher(
    id: 'p',
    displayName: 'Publisher',
    validation: 'verified',
  ),
  categories: const [
    SnapCategory(name: 'development'),
    SnapCategory(name: 'featured'),
    SnapCategory(name: 'not-a-category'),
  ],
  media: const [
    SnapMedia(type: 'icon', url: 'https://example.com/icon.png'),
    SnapMedia(type: 'screenshot', url: 'https://example.com/shot.png'),
  ],
  channels: {'latest/stable': _stable, 'latest/beta': _beta},
);

Snap _localSnap({
  String channel = 'latest/stable',
  int revision = 1,
  RefreshInhibit? refreshInhibit,
}) => createSnap(
  name: 'testsnap',
  title: 'Test Snap',
  version: '1.0',
  revision: revision,
  trackingChannel: channel,
  installedSize: 100,
  installDate: DateTime(2026, 2, 3),
  refreshInhibit: refreshInhibit,
);

void main() {
  tearDown(resetAllServices);

  group('mapping', () {
    test('uninstalled snap', () {
      final snapshot = snapSnapshotFromData(
        SnapData(name: 'testsnap', localSnap: null, storeSnap: _storeSnap),
      );

      expect(snapshot.key, testSnapKey);
      expect(snapshot.installState, InstallState.notInstalled);
      expect(snapshot.appName.valueOrNull, 'Test Snap');
      expect(
        snapshot.icon.valueOrNull,
        const ImageRef.network('https://example.com/icon.png'),
      );
      expect(snapshot.description.valueOrNull?.type, RichContentType.markdown);
      expect(snapshot.screenshots.valueOrNull, [
        'https://example.com/shot.png',
      ]);
      expect(
        snapshot.publisher.valueOrNull?.validation,
        PublisherValidation.verified,
      );
      expect(snapshot.categories.valueOrNull, [AppCategory.development]);
      expect(snapshot.ageRating, isA<FieldUnavailable<ContentRatingLevel>>());
      expect(snapshot.installDate, isA<FieldUnavailable<DateTime>>());
      expect(snapshot.installCandidate?.candidateId, 'rev:2');
      expect(snapshot.installCandidate?.size.valueOrNull?.bytes, 50);
      expect(snapshot.targets.map((t) => t.id), [
        'latest/stable',
        'latest/beta',
      ]);
      expect(snapshot.targets.any((t) => t.isInstalled), isFalse);
      expect(snapshot.activeOperation, isNull);
    });

    test('unknown store size stays unavailable', () {
      final snapshot = snapSnapshotFromData(
        SnapData(name: 'testsnap', localSnap: null, storeSnap: _storeSnap),
      );
      final beta = snapshot.targets.last.candidate!;
      expect(beta.size, isA<FieldUnavailable<ByteSize>>());
      expect(beta.confinement, AppConfinement.classic);
    });

    test('installed snap with an update', () {
      final snapshot = snapSnapshotFromData(
        SnapData(
          name: 'testsnap',
          localSnap: _localSnap(),
          storeSnap: _storeSnap,
          hasUpdate: true,
        ),
        canLaunch: true,
      );

      expect(snapshot.installState, InstallState.installed);
      expect(snapshot.installed?.candidateId, 'rev:1');
      expect(snapshot.installed?.size.valueOrNull?.kind, SizeKind.installed);
      // Revision 1 is not the one the channel reports, so its date is unknown.
      expect(
        snapshot.installed?.releaseDate,
        isA<FieldUnavailable<DateTime>>(),
      );
      expect(snapshot.updateCandidate?.candidateId, 'rev:2');
      expect(
        snapshot.updateCandidate?.size.valueOrNull?.kind,
        SizeKind.download,
      );
      expect(snapshot.installCandidate, isNull);
      expect(snapshot.installDate.valueOrNull, DateTime(2026, 2, 3));
      expect(snapshot.capabilities.canLaunch, isTrue);
      expect(
        snapshot.targets.where((t) => t.isInstalled).single.id,
        'latest/stable',
      );
    });

    test('release date requires the exact revision', () {
      final snapshot = snapSnapshotFromData(
        SnapData(
          name: 'testsnap',
          localSnap: _localSnap(revision: 2),
          storeSnap: _storeSnap,
        ),
      );
      expect(snapshot.installed?.releaseDate.valueOrNull, DateTime(2026, 1, 2));
      expect(snapshot.updateCandidate, isNull);
    });

    test('running app blocks updating', () {
      final snapshot = snapSnapshotFromData(
        SnapData(
          name: 'testsnap',
          localSnap: _localSnap(
            refreshInhibit: RefreshInhibit(proceedTime: DateTime(2026)),
          ),
          storeSnap: _storeSnap,
          hasUpdate: true,
        ),
      );
      expect(snapshot.capabilities.updateBlocked, DisabledReason.appRunning);
    });

    test('installed channel missing from the store is still a target', () {
      final snapshot = snapSnapshotFromData(
        SnapData(
          name: 'testsnap',
          localSnap: _localSnap(channel: 'latest/edge'),
          storeSnap: null,
        ),
      );
      expect(snapshot.targets.single.id, 'latest/edge');
      expect(snapshot.targets.single.isInstalled, isTrue);
      expect(snapshot.screenshots, isA<FieldUnavailable<List<String>>>());
      expect(snapshot.categories, isA<FieldUnavailable<List<AppCategory>>>());
    });

    test('active changes are observed operations', () {
      SnapdChange change(String kind) =>
          SnapdChange(id: 'c', kind: kind, spawnTime: DateTime(2026));
      ObservedOperation? observe(String kind, {Snap? local}) =>
          snapSnapshotFromData(
            SnapData(
              name: 'testsnap',
              localSnap: local,
              storeSnap: _storeSnap,
              activeChangeId: 'c',
            ),
            change: change(kind),
          ).activeOperation;

      expect(observe('install-snap')?.kind, OperationKind.install);
      expect(
        observe('remove-snap', local: _localSnap())?.kind,
        OperationKind.remove,
      );
      expect(
        observe('refresh-snap', local: _localSnap())?.kind,
        OperationKind.update,
      );
      expect(observe('install-snap')?.progress, isNull);
      expect(observe('install-snap')?.cancellable, isTrue);
    });

    test('store failure keeps the local state', () {
      final snapshot = snapSnapshotWithoutStore('testsnap', _localSnap());
      expect(snapshot.installState, InstallState.installed);
      expect(snapshot.appName, isA<FieldFailed<String>>());
      expect(snapshot.installed?.candidateId, 'rev:1');
    });
  });

  group('provider', () {
    test('maps the snap model', () async {
      registerMockSnapdService(storeSnap: _storeSnap);
      final container = createContainer();
      container.listen(snapSourceSnapshotProvider('testsnap'), (_, _) {});
      await settle();

      final snapshot = container
          .read(snapSourceSnapshotProvider('testsnap'))
          .requireValue;
      expect(snapshot.installState, InstallState.notInstalled);
    });

    test('store failure still reports that the snap is absent', () async {
      final service = registerMockSnapdService();
      when(service.getSnap(any)).thenThrow(
        SnapdException(message: 'not installed', kind: 'snap-not-found'),
      );
      when(service.find(name: anyNamed('name'))).thenThrow(
        SnapdException(message: 'offline', kind: 'network-timeout'),
      );
      final container = createContainer();
      container.listen(snapSourceSnapshotProvider('testsnap'), (_, _) {});
      await settle();

      final value = container.read(snapSourceSnapshotProvider('testsnap'));
      expect(value.hasError, isTrue);
      expect(value.valueOrNull?.installState, InstallState.notInstalled);
      expect(value.valueOrNull?.appName, isA<FieldFailed<String>>());
    });
  });

  group('commands', () {
    const backend = SnapDetailsBackend();

    Future<OperationOutcome> execute(
      ProviderContainer container,
      OperationKind kind, {
      String? targetId,
    }) => backend.execute(
      container.read(_refProvider),
      testSnapKey,
      PackageCommand(kind: kind, targetId: targetId),
    );

    test('installs the explicit channel', () async {
      final service = registerMockSnapdService(storeSnap: _storeSnap);
      final container = createContainer();

      expect(
        await execute(
          container,
          OperationKind.install,
          targetId: 'latest/beta',
        ),
        OperationOutcome.success,
      );
      verify(
        service.install('testsnap', channel: 'latest/beta', classic: true),
      ).called(1);
    });

    test('rejects an unknown channel', () async {
      final service = registerMockSnapdService(storeSnap: _storeSnap);
      final container = createContainer();

      expect(
        await execute(container, OperationKind.install, targetId: 'nope'),
        OperationOutcome.failed,
      );
      verifyNever(
        service.install(
          any,
          channel: anyNamed('channel'),
          classic: anyNamed('classic'),
        ),
      );
    });

    test('update stays on the tracking channel', () async {
      final service = registerMockSnapdService(
        localSnap: _localSnap(),
        storeSnap: _storeSnap,
      );
      final container = createContainer();

      expect(
        await execute(
          container,
          OperationKind.update,
          targetId: 'latest/stable',
        ),
        OperationOutcome.success,
      );
      verify(
        service.refresh('testsnap', channel: 'latest/stable'),
      ).called(1);
    });

    test('update of a stale channel is refused', () async {
      final service = registerMockSnapdService(
        localSnap: _localSnap(),
        storeSnap: _storeSnap,
      );
      final container = createContainer();

      expect(
        await execute(container, OperationKind.update, targetId: 'latest/beta'),
        OperationOutcome.failed,
      );
      verifyNever(
        service.refresh(
          any,
          channel: anyNamed('channel'),
          classic: anyNamed('classic'),
        ),
      );
    });

    test('switches channel in place', () async {
      final service = registerMockSnapdService(
        localSnap: _localSnap(),
        storeSnap: _storeSnap,
      );
      final container = createContainer();

      expect(
        await execute(
          container,
          OperationKind.switchChannel,
          targetId: 'latest/beta',
        ),
        OperationOutcome.success,
      );
      verify(
        service.refresh('testsnap', channel: 'latest/beta', classic: true),
      ).called(1);
    });

    test('removes', () async {
      final service = registerMockSnapdService(
        localSnap: _localSnap(),
        storeSnap: _storeSnap,
      );
      final container = createContainer();

      expect(
        await execute(container, OperationKind.remove),
        OperationOutcome.success,
      );
      verify(service.remove('testsnap')).called(1);
    });

    test('declined authorization is a cancellation', () async {
      final service = registerMockSnapdService(storeSnap: _storeSnap);
      when(
        service.install(
          any,
          channel: anyNamed('channel'),
          classic: anyNamed('classic'),
        ),
      ).thenThrow(SnapdException(message: 'no', kind: 'auth-cancelled'));
      final container = createContainer();

      expect(
        await execute(
          container,
          OperationKind.install,
          targetId: 'latest/stable',
        ),
        OperationOutcome.cancelled,
      );
    });

    test('failed change is a failure', () async {
      final service = registerMockSnapdService(storeSnap: _storeSnap);
      when(service.watchChange(any)).thenAnswer(
        (_) => Stream.value(
          SnapdChange(id: 'id', spawnTime: DateTime(2026), err: 'broken'),
        ),
      );
      final container = createContainer();

      expect(
        await execute(
          container,
          OperationKind.install,
          targetId: 'latest/stable',
        ),
        OperationOutcome.failed,
      );
    });
  });
}
