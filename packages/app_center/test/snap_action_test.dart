import 'package:app_center/l10n.dart';
import 'package:app_center/manage/app_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/snap_updates_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  group('SnapAction', () {
    testWidgets('revert action has correct label', (tester) async {
      await tester.pumpApp((context) {
        final l10n = AppLocalizations.of(context);
        expect(
          SnapAction.revert.label(l10n),
          equals(l10n.snapActionRevertLabel),
        );
        return const SizedBox.shrink();
      });
    });

    test('revert action has correct icon', () {
      expect(SnapAction.revert.icon, equals(YaruIcons.undo));
    });

    test(
      'revert callback is available when a previous local revision exists',
      () async {
        final container = createContainer();
        registerMockSnapdService(localSnap: createSnap(name: 'test'));
        final model = container.read(snapModelProvider('test').notifier);
        final snapData = SnapData(
          name: 'test',
          localSnap: createSnap(name: 'test'),
          storeSnap: null,
          hasPreviousLocalRevision: true, // defaults are fine
        );

        final callback = SnapAction.revert.callback(snapData, model);
        expect(callback, isNotNull);
      },
    );

    test('revert callback is null for uninstalled snaps', () async {
      final container = createContainer();
      registerMockSnapdService(storeSnap: createSnap(name: 'test'));
      final model = container.read(snapModelProvider('test').notifier);
      final snapData = SnapData(
        name: 'test',
        localSnap: null,
        storeSnap: createSnap(name: 'test'),
      );

      final callback = SnapAction.revert.callback(snapData, model);
      expect(callback, isNull);
    });

    test('revert callback is null when no previous revision', () async {
      final container = createContainer();
      registerMockSnapdService(storeSnap: createSnap(name: 'test'));
      final model = container.read(snapModelProvider('test').notifier);
      final snapData = SnapData(
        name: 'test',
        localSnap: null,
        storeSnap: createSnap(name: 'test'),
      );

      final callback = SnapAction.revert.callback(snapData, model);
      expect(callback, isNull);
    });

    test('update callback is null without a store snap', () async {
      final container = createContainer();
      registerMockSnapdService(localSnap: createSnap(name: 'test'));
      final model = container.read(snapModelProvider('test').notifier);
      final snapData = SnapData(
        name: 'test',
        localSnap: createSnap(name: 'test'),
        storeSnap: null,
      );

      expect(SnapAction.update.callback(snapData, model), isNull);
    });

    test('update callback is available with a store snap', () async {
      final container = createContainer();
      registerMockSnapdService(storeSnap: createSnap(name: 'test'));
      final model = container.read(snapModelProvider('test').notifier);
      final snapData = SnapData(
        name: 'test',
        localSnap: null,
        storeSnap: createSnap(name: 'test'),
      );

      expect(SnapAction.update.callback(snapData, model), isNotNull);
    });

    test(
      'update callback refreshes the snap and moves it from the updates list '
      'to the installed list',
      () async {
        final localSnap = createSnap(
          name: 'test',
          version: '1.0',
          revision: 1,
          trackingChannel: 'latest/stable',
          apps: [const SnapApp(name: 'test')],
        );
        final storeSnap = createSnap(
          name: 'test',
          version: '2.0',
          revision: 2,
          channels: {
            'latest/stable': SnapChannel(
              confinement: SnapConfinement.strict,
              size: 1337,
              releasedAt: DateTime(1970),
              version: '2.0',
            ),
          },
        );
        final service = registerMockSnapdService(
          localSnap: localSnap,
          storeSnap: storeSnap,
          installedSnaps: [localSnap],
          refreshableSnaps: [storeSnap],
        );

        final container = createContainer(
          overrides: [
            localDebsProvider.overrideWith((ref) async => []),
            showLocalSystemAppsProvider.overrideWith((ref) => true),
          ],
        );

        container.listen(installedAppsProvider, (_, __) {});
        container.listen(filteredLocalSnapsProvider, (_, __) {});

        final updates = await container.read(snapUpdatesModelProvider.future);
        expect(updates.snaps.snapNames, contains('test'));
        final installedBefore = await container.read(
          installedAppsProvider.future,
        );
        expect(installedBefore.map((a) => a.name), isNot(contains('test')));

        final model = container.read(snapModelProvider('test').notifier);
        final snapData = await container.read(snapModelProvider('test').future);
        expect(snapData.hasUpdate, isTrue);

        final callback = SnapAction.update.callback(snapData, model);
        expect(callback, isNotNull);
        callback!();

        await settle();

        verify(
          service.refresh(
            'test',
            channel: anyNamed('channel'),
            classic: anyNamed('classic'),
          ),
        ).called(1);

        expect(
          container.read(snapUpdatesModelProvider).value!.snaps.snapNames,
          isNot(contains('test')),
        );
        expect(
          container.read(installedAppsProvider).value!.map((a) => a.name),
          contains('test'),
        );
        expect(
          container.read(filteredLocalSnapsProvider).value!.snaps.snapNames,
          contains('test'),
        );
      },
    );
  });
}
