import 'package:app_center/manage/deb_updates_provider.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/snap_updates_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';

import 'test_utils.dart';

void main() {
  group('snap providers', () {
    test('no updates available', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(name: 'firefox'),
          createSnap(name: 'thunderbird'),
        ],
      );
      final container = createContainer();
      final nonRefreshableSnaps =
          await container.read(localSnapsProvider.future);
      final refreshableSnaps = await container.read(snapUpdatesProvider.future);

      expect(
        nonRefreshableSnaps,
        equals(
          SnapListState(
            snaps: [
              createSnap(name: 'firefox'),
              createSnap(name: 'thunderbird'),
            ],
          ),
        ),
      );
      expect(refreshableSnaps, isEmpty);
    });

    test('update available', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(name: 'firefox'),
          createSnap(name: 'thunderbird'),
        ],
        refreshableSnaps: [
          createSnap(name: 'firefox'),
        ],
      );
      final container = createContainer();
      final installedSnaps = await container.read(localSnapsProvider.future);
      final refreshableSnaps = await container.read(snapUpdatesProvider.future);

      // Refreshable snaps appear in BOTH lists - installed list contains all snaps
      expect(
        installedSnaps,
        equals(
          SnapListState(
            snaps: [
              createSnap(name: 'firefox'),
              createSnap(name: 'thunderbird'),
            ],
          ),
        ),
      );
      // Updates list contains only snaps with updates available
      expect(
        refreshableSnaps,
        equals(
          SnapListState(snaps: [createSnap(name: 'firefox')]),
        ),
      );
    });
  });

  group('InstalledDebs provider', () {
    test('returns installed debs from appstream components', () async {
      registerDebMocks([
        const DebMockEntry(
          id: 'gimp',
          name: 'GIMP',
          version: '2.10',
          size: 50000,
        ),
        const DebMockEntry(
          id: 'inkscape',
          name: 'Inkscape',
          version: '1.2',
          size: 30000,
        ),
      ]);

      final container = createContainer();
      final debs = await container.read(installedDebsProvider.future);

      expect(debs, hasLength(2));
      expect(debs.map((d) => d.id), containsAll(['gimp', 'inkscape']));

      final gimp = debs.firstWhere((d) => d.id == 'gimp');
      expect(gimp.name, equals('GIMP'));
      expect(gimp.version, equals('2.10'));
      expect(gimp.installedSize, equals(50000));
    });

    test('skips unresolved packages', () async {
      createMockAppstreamService(
        components: [
          createAppstreamComponent(
            id: 'gimp',
            name: 'GIMP',
            packageName: 'gimp',
          ),
          createAppstreamComponent(
            id: 'missing',
            name: 'Missing App',
            packageName: 'missing-pkg',
          ),
        ],
      );

      final packageKit = createMockPackageKitService();
      when(
        packageKit.resolve(any, installedOnly: true),
      ).thenAnswer(
        (_) async => {
          'gimp': const PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: PackageKitPackageId(name: 'gimp', version: '2.10'),
            summary: 'GNU Image Manipulation Program',
          ),
          'missing-pkg': null,
        },
      );

      final container = createContainer();
      final debs = await container.read(installedDebsProvider.future);

      expect(debs, hasLength(1));
      expect(debs.first.id, equals('gimp'));
    });

    test('removeFromList removes a deb', () async {
      registerDebMocks([
        const DebMockEntry(id: 'gimp', name: 'GIMP', version: '2.10'),
      ]);

      final container = createContainer();
      var debs = await container.read(installedDebsProvider.future);
      expect(debs, hasLength(1));

      container.read(installedDebsProvider.notifier).removeFromList('gimp');
      debs = container.read(installedDebsProvider).value!;
      expect(debs, isEmpty);
    });
  });

  group('DebUpdates provider', () {
    test('no updates available', () async {
      registerDebMocks([
        const DebMockEntry(id: 'gimp', name: 'GIMP', version: '2.10'),
      ]);

      final container = createContainer();
      final updates = await container.read(debUpdatesProvider.future);
      expect(updates, isEmpty);
    });

    test('detects updates with different version', () async {
      registerDebMocks([
        const DebMockEntry(
          id: 'gimp',
          name: 'GIMP',
          version: '2.10',
          updateVersion: '2.11',
        ),
      ]);

      final container = createContainer();
      final updates = await container.read(debUpdatesProvider.future);

      expect(updates, hasLength(1));
      expect(updates.first.id, equals('gimp'));
      expect(updates.first.hasUpdate, isTrue);
      expect(updates.first.updateVersion, equals('2.11'));
      expect(updates.first.updatePackageId?.version, equals('2.11'));
    });

    test('ignores updates with same version', () async {
      registerDebMocks([
        const DebMockEntry(
          id: 'gimp',
          name: 'GIMP',
          version: '2.10',
          updateVersion: '2.10',
        ),
      ]);

      final container = createContainer();
      final updates = await container.read(debUpdatesProvider.future);
      expect(updates, isEmpty);
    });

    test('removeFromList removes from updates', () async {
      registerDebMocks([
        const DebMockEntry(
          id: 'gimp',
          name: 'GIMP',
          version: '2.10',
          updateVersion: '2.11',
        ),
      ]);

      final container = createContainer();
      var updates = await container.read(debUpdatesProvider.future);
      expect(updates, hasLength(1));

      container.read(debUpdatesProvider.notifier).removeFromList('gimp');
      updates = container.read(debUpdatesProvider).value!;
      expect(updates, isEmpty);
    });
  });

  group('debUpdateInfo provider', () {
    test('returns data for existing deb update', () async {
      registerDebMocks([
        const DebMockEntry(
          id: 'gimp',
          name: 'GIMP',
          version: '2.10',
          updateVersion: '2.11',
        ),
      ]);

      final container = createContainer();
      await container.read(debUpdatesProvider.future);

      final info = container.read(debUpdateInfoProvider('gimp'));
      expect(info, isNotNull);
      expect(info!.updateVersion, equals('2.11'));
    });

    test('returns null for missing deb', () async {
      createMockAppstreamService(components: []);
      createMockPackageKitService();

      final container = createContainer();
      await container.read(debUpdatesProvider.future);

      final info = container.read(debUpdateInfoProvider('nonexistent'));
      expect(info, isNull);
    });
  });
}
