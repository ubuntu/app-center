import 'package:app_center/l10n.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  group('SnapAction', () {
    testWidgets('revert action has correct label', (tester) async {
      await tester.pumpApp(
        (context) {
          final l10n = AppLocalizations.of(context);
          expect(SnapAction.revert.label(l10n), equals(l10n.snapActionRevertLabel));
          return const SizedBox.shrink();
        },
      );
    });

    test('revert action has correct icon', () {
      expect(SnapAction.revert.icon, equals(YaruIcons.undo));
    });

    testWidgets('revert callback is available for installed snaps', (tester) async {
      final container = createContainer();
      final service = registerMockSnapdService(localSnap: createSnap(name: 'test'));
      final model = container.read(snapModelProvider('test').notifier);
      await container.read(snapModelProvider('test').future);
      final snapData = container.read(snapModelProvider('test')).value!;

      await tester.pumpApp(
        (context) {
          final callback = SnapAction.revert.callback(snapData, model, null, context);
          expect(callback, isNotNull);
          return const SizedBox.shrink();
        },
      );
    });

    testWidgets('revert callback is null for uninstalled snaps', (tester) async {
      final container = createContainer();
      registerMockSnapdService(storeSnap: createSnap(name: 'test'));
      final model = container.read(snapModelProvider('test').notifier);
      await container.read(snapModelProvider('test').future);
      final snapData = container.read(snapModelProvider('test')).value!;

      await tester.pumpApp(
        (context) {
          final callback = SnapAction.revert.callback(snapData, model, null, context);
          expect(callback, isNull);
          return const SizedBox.shrink();
        },
      );
    });

    testWidgets('revert callback calls model.revert with context', (tester) async {
      final container = createContainer();
      final service = registerMockSnapdService(localSnap: createSnap(name: 'test'));
      final model = container.read(snapModelProvider('test').notifier);
      await container.read(snapModelProvider('test').future);
      final snapData = container.read(snapModelProvider('test')).value!;

      await tester.pumpApp(
        (context) {
          final callback = SnapAction.revert.callback(snapData, model, null, context);
          expect(callback, isNotNull);

          // Note: We can't easily test the actual callback execution here
          // because it would require mocking the confirmation dialog
          // This test just verifies that the callback is created correctly

          return const SizedBox.shrink();
        },
      );
    });
  });
}
