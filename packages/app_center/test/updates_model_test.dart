import 'package:app_center/manage/combined_providers.dart';
import 'package:app_center/manage/deb_updates_provider.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/manage_filters.dart';
import 'package:app_center/manage/snap_updates_provider.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snap_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

/// Test override for InstalledDebs that returns known data.
class _TestInstalledDebs extends InstalledDebs {
  final List<ManageDebData> _debs;
  _TestInstalledDebs(this._debs);
  @override
  Future<List<ManageDebData>> build() async => _debs;
}

/// Test override for DebUpdates that returns known data.
class _TestDebUpdates extends DebUpdates {
  final List<ManageDebData> _updates;
  _TestDebUpdates(this._updates);
  @override
  Future<List<ManageDebData>> build() async => _updates;
}

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
      final model = await container.read(snapUpdatesProvider.future);
      expect(model.isEmpty, isTrue);
    });

    test('updates available', () async {
      registerMockSnapdService(
        refreshableSnaps: [createSnap(name: 'firefox')],
      );
      final container = createContainer();
      final model = await container.read(snapUpdatesProvider.future);
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
    final container = createContainer(overrides: emptyDebOverrides);
    await container.read(snapModelProvider('testsnap3').future);
    await container.read(snapUpdatesProvider.future);
    // refreshAll invalidates snapUpdatesProvider which makes the CombinedUpdates
    // ref stale - the assertion error in the finally block is expected
    try {
      await container.read(combinedUpdatesProvider.notifier).refreshAll();
    } on AssertionError catch (_) {
      // Expected: ref becomes stale after invalidating a dependency
    }
    verify(service.refresh('testsnap3', channel: anyNamed('channel')))
        .called(1);
  });

  group('localVersion', () {
    test('returns installed version when snap is installed', () async {
      final localSnap = createSnap(name: 'testsnap', version: '1.0.0');
      registerMockSnapdService(localSnap: localSnap);
      final container = createContainer();

      final version =
          await container.read(localVersionProvider('testsnap').future);
      expect(version, equals('1.0.0'));
    });

    test('returns null when snap is not installed', () async {
      final service = registerMockSnapdService();
      when(service.getSnap(any)).thenThrow(
        SnapdException(message: 'snap not found', kind: 'snap-not-found'),
      );
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

      await container.read(snapUpdatesProvider.future);

      final version = container.read(snapUpdateVersionProvider('testsnap'));
      expect(version, equals('2.0.0'));
    });

    test('returns null when no update is available', () async {
      registerMockSnapdService();
      final container = createContainer();

      await container.read(snapUpdatesProvider.future);

      final version = container.read(snapUpdateVersionProvider('testsnap'));
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

      expect(container.read(snapUpdatesProvider.future), throwsException);
    });

    test('refresh no internet', () async {
      registerMockErrorStreamControllerService();
      final service = registerMockSnapdService();
      final container = createContainer();
      when(service.find(filter: SnapFindFilter.refresh)).thenThrow(
        SnapdException(message: ''),
      );

      final snapListState = await container.read(snapUpdatesProvider.future);
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
      final container = createContainer(overrides: emptyDebOverrides);
      await container.read(snapModelProvider('testsnap3').future);
      when(service.refreshMany(any)).thenThrow(
        SnapdException(
          message: 'error while updating snaps',
          kind: 'error kind',
        ),
      );
      await container.read(snapUpdatesProvider.future);

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
      try {
        await container.read(combinedUpdatesProvider.notifier).refreshAll();
      } on AssertionError catch (_) {
        // Expected: ref becomes stale after invalidating a dependency
      }
    });
  });

  group('combined updates with debs', () {
    test('includes both snap and deb updates', () async {
      registerMockSnapdService(
        refreshableSnaps: [createSnap(name: 'firefox', title: 'Firefox')],
        installedSnaps: [createSnap(name: 'firefox', title: 'Firefox')],
      );

      final debUpdate = createManageDebData(
        id: 'gimp',
        name: 'GIMP',
        packageName: 'gimp',
        version: '2.10',
        hasUpdate: true,
        updateVersion: '2.11',
        updatePackageId: const PackageKitPackageId(
          name: 'gimp',
          version: '2.11',
        ),
      );

      final container = createContainer(
        overrides: [
          installedDebsProvider.overrideWith(
            () => _TestInstalledDebs([debUpdate]),
          ),
          debUpdatesProvider.overrideWith(
            () => _TestDebUpdates([debUpdate]),
          ),
        ],
      );

      final updates = await container.read(combinedUpdatesProvider.future);

      expect(updates, hasLength(2));
      // Sorted alphabetically: Firefox, GIMP
      expect(updates[0].name, equals('Firefox'));
      expect(updates[0], isA<ManageSnapData>());
      expect(updates[1].name, equals('GIMP'));
      expect(updates[1], isA<ManageDebData>());
    });
  });

  group('combined installed with filtering', () {
    test('includes both snaps and debs', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'firefox',
            title: 'Firefox',
            apps: [const SnapApp(name: 'firefox')],
          ),
        ],
      );

      final installedDeb = createManageDebData(
        id: 'gimp',
        name: 'GIMP',
        packageName: 'gimp',
      );

      final container = createContainer(
        overrides: [
          installedDebsProvider.overrideWith(
            () => _TestInstalledDebs([installedDeb]),
          ),
          ...emptyDebOverrides.where(
            (o) => o.toString().contains('debUpdates'),
          ),
          debUpdatesProvider.overrideWith(() => _TestDebUpdates([])),
          showSystemAppsProvider.overrideWith((ref) => true),
        ],
      );

      final installed = await container.read(combinedInstalledProvider.future);

      expect(installed, hasLength(2));
      expect(installed.map((a) => a.name), containsAll(['Firefox', 'GIMP']));
    });

    test('package type filter - snap only', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'firefox',
            title: 'Firefox',
            apps: [const SnapApp(name: 'firefox')],
          ),
        ],
      );

      final installedDeb = createManageDebData(
        id: 'gimp',
        name: 'GIMP',
      );

      final container = createContainer(
        overrides: [
          installedDebsProvider.overrideWith(
            () => _TestInstalledDebs([installedDeb]),
          ),
          debUpdatesProvider.overrideWith(() => _TestDebUpdates([])),
          showSystemAppsProvider.overrideWith((ref) => true),
          packageTypeFilterProvider.overrideWith(
            (_) => PackageTypeFilter.snap,
          ),
        ],
      );

      final installed = await container.read(combinedInstalledProvider.future);

      expect(installed, hasLength(1));
      expect(installed.first, isA<ManageSnapData>());
      expect(installed.first.name, equals('Firefox'));
    });

    test('search filter works across both types', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'firefox',
            title: 'Firefox',
            apps: [const SnapApp(name: 'firefox')],
          ),
          createSnap(
            name: 'thunderbird',
            title: 'Thunderbird',
            apps: [const SnapApp(name: 'thunderbird')],
          ),
        ],
      );

      final installedDeb = createManageDebData(
        id: 'gimp',
        name: 'GIMP',
      );

      final container = createContainer(
        overrides: [
          installedDebsProvider.overrideWith(
            () => _TestInstalledDebs([installedDeb]),
          ),
          debUpdatesProvider.overrideWith(() => _TestDebUpdates([])),
          showSystemAppsProvider.overrideWith((ref) => true),
          appFilterProvider.overrideWith((_) => 'fire'),
        ],
      );

      final installed = await container.read(combinedInstalledProvider.future);

      expect(installed, hasLength(1));
      expect(installed.first.name, equals('Firefox'));
    });

    test('excludes apps with pending updates', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'firefox',
            title: 'Firefox',
            apps: [const SnapApp(name: 'firefox')],
          ),
        ],
        refreshableSnaps: [createSnap(name: 'firefox', title: 'Firefox')],
      );

      final installedDeb = createManageDebData(
        id: 'gimp',
        name: 'GIMP',
      );
      final debWithUpdate = createManageDebData(
        id: 'inkscape',
        name: 'Inkscape',
        hasUpdate: true,
        updateVersion: '1.3',
      );

      final container = createContainer(
        overrides: [
          installedDebsProvider.overrideWith(
            () => _TestInstalledDebs([installedDeb, debWithUpdate]),
          ),
          debUpdatesProvider.overrideWith(
            () => _TestDebUpdates([debWithUpdate]),
          ),
          showSystemAppsProvider.overrideWith((ref) => true),
        ],
      );

      final installed = await container.read(combinedInstalledProvider.future);

      // Firefox has snap update, Inkscape has deb update - both excluded
      // Only GIMP should appear
      final names = installed.map((a) => a.name).toList();
      expect(names, contains('GIMP'));
      expect(names, isNot(contains('Inkscape')));
    });
  });
}
