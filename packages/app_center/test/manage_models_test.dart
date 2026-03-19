import 'package:app_center/appstream/appstream_utils.dart';
import 'package:app_center/manage/app_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_deb_updates_model.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/snap_updates_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  test('no updates available', () async {
    registerMockSnapdService(
      installedSnaps: [
        createSnap(name: 'firefox'),
        createSnap(name: 'thunderbird'),
      ],
    );
    final container = createContainer();
    container.read(showLocalSystemAppsProvider.notifier).state = true;
    final nonRefreshableSnaps =
        await container.read(filteredLocalSnapsProvider.future);
    final refreshableSnaps =
        await container.read(snapUpdatesModelProvider.future);

    expect(
      nonRefreshableSnaps,
      equals(
        SnapListState(
          snaps: [createSnap(name: 'firefox'), createSnap(name: 'thunderbird')],
        ),
      ),
    );
    expect(refreshableSnaps.isEmpty, isTrue);
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
    container.read(showLocalSystemAppsProvider.notifier).state = true;
    final nonRefreshableSnaps =
        await container.read(filteredLocalSnapsProvider.future);
    final refreshableSnaps =
        await container.read(snapUpdatesModelProvider.future);

    expect(
      nonRefreshableSnaps,
      equals(
        SnapListState(snaps: [createSnap(name: 'thunderbird')]),
      ),
    );
    expect(
      refreshableSnaps,
      equals(
        SnapListState(snaps: [createSnap(name: 'firefox')]),
      ),
    );
  });

  group('localDebs provider', () {
    tearDown(resetAllServices);

    test('returns installed debs from appstream components', () async {
      createMockAppstreamService(
        components: [
          createAppstreamComponent(
            id: 'gimp',
            name: 'GIMP',
            packageName: 'gimp',
          ),
          createAppstreamComponent(
            id: 'inkscape',
            name: 'Inkscape',
            packageName: 'inkscape',
          ),
        ],
      );
      createMockPackageKitService(
        installedPackages: [
          const PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: PackageKitPackageId(name: 'gimp', version: '2.10'),
            summary: 'GNU Image Manipulation Program',
          ),
          const PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: PackageKitPackageId(name: 'inkscape', version: '1.2'),
            summary: 'Vector Graphics Editor',
          ),
        ],
        packageDetailsMany: {
          'gimp': PackageKitDetailsEvent(
            packageId: const PackageKitPackageId(name: 'gimp', version: '2.10'),
            size: 50000,
          ),
          'inkscape': PackageKitDetailsEvent(
            packageId:
                const PackageKitPackageId(name: 'inkscape', version: '1.2'),
            size: 30000,
          ),
        },
      );

      final container = createContainer();
      final debs = await container.read(localDebsProvider.future);

      expect(debs, hasLength(2));
      expect(debs.map((d) => d.id), containsAll(['gimp', 'inkscape']));

      final gimp = debs.firstWhere((d) => d.id == 'gimp');
      expect(gimp.component?.getLocalizedName(), equals('GIMP'));
      expect(gimp.packageInfo.packageId.version, equals('2.10'));
      expect(gimp.details?.size, equals(50000));
    });

    test('skips packages without appstream entries', () async {
      createMockAppstreamService(
        components: [
          createAppstreamComponent(
            id: 'gimp',
            name: 'GIMP',
            packageName: 'gimp',
          ),
        ],
      );
      createMockPackageKitService(
        installedPackages: [
          const PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: PackageKitPackageId(name: 'gimp', version: '2.10'),
            summary: 'GNU Image Manipulation Program',
          ),
          const PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: PackageKitPackageId(name: 'system-pkg', version: '1.0'),
            summary: 'System Package',
          ),
        ],
      );

      final container = createContainer();
      final debs = await container.read(localDebsProvider.future);

      expect(debs, hasLength(1));
      expect(debs.first.id, equals('gimp'));
    });

    test('includes update info when available', () async {
      createMockAppstreamService(
        components: [
          createAppstreamComponent(
            id: 'gimp',
            name: 'GIMP',
            packageName: 'gimp',
          ),
        ],
      );
      createMockPackageKitService(
        installedPackages: [
          const PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: PackageKitPackageId(name: 'gimp', version: '2.10'),
            summary: 'GNU Image Manipulation Program',
          ),
        ],
        availableUpdates: [
          const PackageKitPackageEvent(
            info: PackageKitInfo.available,
            packageId: PackageKitPackageId(name: 'gimp', version: '2.11'),
            summary: 'GIMP update',
          ),
        ],
      );

      final container = createContainer();
      final debs = await container.read(localDebsProvider.future);

      expect(debs, hasLength(1));
      expect(debs.first.hasUpdate, isTrue);
      expect(debs.first.updateVersion, equals('2.11'));
    });
  });

  group('localDebUpdatesModel provider', () {
    tearDown(resetAllServices);

    test('no updates available when no debs have updates', () async {
      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultInstalledDeb]),
        ],
      );
      final updates = await container.read(localDebUpdatesModelProvider.future);
      expect(updates, isEmpty);
    });

    test('removeFromList removes a deb', () async {
      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultDebWithUpdate]),
        ],
      );
      var updates = await container.read(localDebUpdatesModelProvider.future);
      expect(updates, hasLength(1));

      container
          .read(localDebUpdatesModelProvider.notifier)
          .removeFromList('inkscape');
      updates = container.read(localDebUpdatesModelProvider).value!;
      expect(updates, isEmpty);
    });
  });

  group('appUpdates provider', () {
    tearDown(resetAllServices);

    test('includes both snap and deb updates', () async {
      registerMockSnapdService(
        refreshableSnaps: [createSnap(name: 'firefox', title: 'Firefox')],
        installedSnaps: [createSnap(name: 'firefox', title: 'Firefox')],
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultDebWithUpdate]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
        ],
      );

      final updates = await container.read(appUpdatesProvider.future);

      expect(updates, hasLength(2));
      expect(updates[0].name, equals('Firefox'));
      expect(updates[0], isA<ManageSnapData>());
      expect(updates[1].name, equals('Inkscape'));
      expect(updates[1], isA<ManageDebData>());
    });
  });

  group('localDebUpdatesModel actions', () {
    tearDown(resetAllServices);

    test('updateAll updates all debs and removes from list', () async {
      registerMockSnapdService(installedSnaps: []);

      final debUpdate2 = createLocalDebInfo(
        id: 'blender',
        name: 'Blender',
        packageName: 'blender',
        version: '3.0',
        updatePackageId: const PackageKitPackageId(
          name: 'blender',
          version: '3.1',
        ),
      );

      final mockPackageKit = createMockPackageKitService();

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith(
            (ref) async => [defaultDebWithUpdate, debUpdate2],
          ),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
      );

      // Initialize installedApps provider (needed for addDebToList)
      await container.read(installedAppsProvider.future);

      // Verify initial state
      var updates = await container.read(localDebUpdatesModelProvider.future);
      expect(updates, hasLength(2));

      // Trigger updateAll
      await container.read(localDebUpdatesModelProvider.notifier).updateAll();

      // Verify updates were called
      verify(mockPackageKit.update(any)).called(2);

      // Verify list is now empty (both removed after update)
      updates = container.read(localDebUpdatesModelProvider).value!;
      expect(updates, isEmpty);
    });

    test('updateAll reports errors to error stream', () async {
      registerMockSnapdService(installedSnaps: []);

      final mockPackageKit = createMockPackageKitService();
      when(mockPackageKit.update(any)).thenThrow(Exception('Update failed'));

      // ignore: close_sinks
      final errorStream = registerMockErrorStreamControllerService();

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultDebWithUpdate]),
        ],
      );

      await container.read(localDebUpdatesModelProvider.future);

      // Trigger updateAll which should fail
      await container.read(localDebUpdatesModelProvider.notifier).updateAll();

      // Verify error was reported
      verify(errorStream.add(any)).called(1);
    });

    test('silentUpdatesCheck updates state when updates change', () async {
      registerMockSnapdService(installedSnaps: []);

      // Start with no updates
      final mockPackageKit = createMockPackageKitService(
        installedPackages: [
          PackageKitPackageEvent(
            info: PackageKitInfo.installed,
            packageId: defaultInstalledDeb.packageInfo.packageId,
            summary: 'Image editor',
          ),
        ],
        availableUpdates: [],
      );
      createMockAppstreamService(
        components: [defaultInstalledDeb.component!],
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => []),
        ],
      );

      var updates = await container.read(localDebUpdatesModelProvider.future);
      expect(updates, isEmpty);

      // Now simulate finding an update
      when(mockPackageKit.getUpdates()).thenAnswer(
        (_) async => [
          const PackageKitPackageEvent(
            info: PackageKitInfo.available,
            packageId: PackageKitPackageId(name: 'gimp', version: '2.11'),
            summary: 'GIMP update',
          ),
        ],
      );

      // Trigger silent check
      await container
          .read(localDebUpdatesModelProvider.notifier)
          .silentUpdatesCheck();

      // Verify update was detected
      updates = container.read(localDebUpdatesModelProvider).value!;
      expect(updates, hasLength(1));
      expect(updates.first.id, equals('gimp'));
    });

    test('cancelTransaction stops in-progress update', () async {
      registerMockSnapdService(installedSnaps: []);

      final debWithTransaction = defaultDebWithUpdate.copyWith(
        activeTransactionId: 42,
      );

      final mockPackageKit = createMockPackageKitService();

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [debWithTransaction]),
        ],
      );

      await container.read(localDebUpdatesModelProvider.future);

      // Cancel the transaction
      await container
          .read(localDebUpdatesModelProvider.notifier)
          .cancelTransaction('inkscape');

      // Verify cancel was called
      verify(mockPackageKit.cancelTransaction(42)).called(1);

      // Verify transaction ID was cleared
      final updates = container.read(localDebUpdatesModelProvider).value!;
      expect(updates.first.activeTransactionId, isNull);
    });
  });

  group('installedApps provider', () {
    tearDown(resetAllServices);

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

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultInstalledDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

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

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultInstalledDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          packageTypeFilterProvider.overrideWith(
            (_) => PackageTypeFilter.snap,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

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

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultInstalledDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          localSnapFilterProvider.overrideWith((_) => 'fire'),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed, hasLength(1));
      expect(installed.first.name, equals('Firefox'));
    });

    test('removeDeb removes deb from list via PackageKit', () async {
      registerMockSnapdService(installedSnaps: []);

      final mockPackageKit = createMockPackageKitService();

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultInstalledDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
      );

      var installed = await container.read(installedAppsProvider.future);
      expect(installed, hasLength(1));
      expect(installed.first.name, equals('GIMP'));

      // Remove the deb
      await container.read(installedAppsProvider.notifier).removeDeb('gimp');

      // Verify PackageKit remove was called
      verify(mockPackageKit.remove(any)).called(1);
      verify(mockPackageKit.waitTransaction(any)).called(1);

      // Verify deb was removed from list
      installed = container.read(installedAppsProvider).value!;
      expect(installed, isEmpty);
    });

    test('package type filter - deb only', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'firefox',
            title: 'Firefox',
            apps: [const SnapApp(name: 'firefox')],
          ),
        ],
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [defaultInstalledDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          packageTypeFilterProvider.overrideWith(
            (_) => PackageTypeFilter.deb,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed, hasLength(1));
      expect(installed.first, isA<ManageDebData>());
      expect(installed.first.name, equals('GIMP'));
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

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith(
            (ref) async => [defaultInstalledDeb, defaultDebWithUpdate],
          ),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      final names = installed.map((a) => a.name).toList();
      expect(names, contains('GIMP'));
      expect(names, isNot(contains('Firefox')));
      expect(names, isNot(contains('Inkscape')));
    });
  });

  group('sorting', () {
    tearDown(resetAllServices);

    test('sort alphabetically ascending', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'zebra',
            title: 'Zebra',
            apps: [const SnapApp(name: 'zebra')],
          ),
        ],
      );

      final installedDeb = createLocalDebInfo(
        id: 'apple',
        name: 'Apple',
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [installedDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          appSortOrderProvider.overrideWith(
            (_) => AppSortOrder.alphabeticalAsc,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed.map((a) => a.name).toList(), ['Apple', 'Zebra']);
    });

    test('sort alphabetically descending', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'apple',
            title: 'Apple',
            apps: [const SnapApp(name: 'apple')],
          ),
        ],
      );

      final installedDeb = createLocalDebInfo(
        id: 'zebra',
        name: 'Zebra',
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [installedDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          appSortOrderProvider.overrideWith(
            (_) => AppSortOrder.alphabeticalDesc,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed.map((a) => a.name).toList(), ['Zebra', 'Apple']);
    });

    test('sort by installed date ascending', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'newer',
            title: 'Newer',
            apps: [const SnapApp(name: 'newer')],
            installDate: DateTime(2024, 6),
          ),
          createSnap(
            name: 'older',
            title: 'Older',
            apps: [const SnapApp(name: 'older')],
            installDate: DateTime(2024),
          ),
        ],
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => []),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          appSortOrderProvider.overrideWith(
            (_) => AppSortOrder.installedDateAsc,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed.map((a) => a.name).toList(), ['Older', 'Newer']);
    });

    test('sort by installed date descending', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'older',
            title: 'Older',
            apps: [const SnapApp(name: 'older')],
            installDate: DateTime(2024),
          ),
          createSnap(
            name: 'newer',
            title: 'Newer',
            apps: [const SnapApp(name: 'newer')],
            installDate: DateTime(2024, 6),
          ),
        ],
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => []),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          appSortOrderProvider.overrideWith(
            (_) => AppSortOrder.installedDateDesc,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed.map((a) => a.name).toList(), ['Newer', 'Older']);
    });

    test('sort by installed size ascending', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'large',
            title: 'Large',
            apps: [const SnapApp(name: 'large')],
            installedSize: 1000000,
          ),
        ],
      );

      final installedDeb = createLocalDebInfo(
        id: 'small',
        name: 'Small',
        size: 100,
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [installedDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          appSortOrderProvider.overrideWith(
            (_) => AppSortOrder.installedSizeAsc,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed.map((a) => a.name).toList(), ['Small', 'Large']);
    });

    test('sort by installed size descending', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'small',
            title: 'Small',
            apps: [const SnapApp(name: 'small')],
            installedSize: 100,
          ),
        ],
      );

      final installedDeb = createLocalDebInfo(
        id: 'large',
        name: 'Large',
        size: 1000000,
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [installedDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          appSortOrderProvider.overrideWith(
            (_) => AppSortOrder.installedSizeDesc,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed.map((a) => a.name).toList(), ['Large', 'Small']);
    });

    test('items without date sort to end', () async {
      registerMockSnapdService(
        installedSnaps: [
          createSnap(
            name: 'with-date',
            title: 'With Date',
            apps: [const SnapApp(name: 'with-date')],
            installDate: DateTime(2024),
          ),
        ],
      );

      // Debs don't have install dates
      final installedDeb = createLocalDebInfo(
        id: 'no-date',
        name: 'No Date',
      );

      final container = createContainer(
        overrides: [
          localDebsProvider.overrideWith((ref) async => [installedDeb]),
          localDebUpdatesModelProvider.overrideWith(LocalDebUpdatesModel.new),
          showLocalSystemAppsProvider.overrideWith((ref) => true),
          appSortOrderProvider.overrideWith(
            (_) => AppSortOrder.installedDateAsc,
          ),
        ],
      );

      final installed = await container.read(installedAppsProvider.future);

      expect(installed.map((a) => a.name).toList(), ['With Date', 'No Date']);
    });
  });
}
