import 'package:app_center/l10n.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    test('revert callback is available when a previous local revision exists',
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
    });

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
  });
}
