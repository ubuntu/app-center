import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  group('SnapData', () {
    test(
        'canRevert returns true for installed snaps with previous local revision',
        () {
      final localSnap = createSnap(name: 'test', version: '1.0.0');
      final snapData = SnapData(
        name: 'test',
        localSnap: localSnap,
        storeSnap: null,
        hasPreviousLocalRevision: true,
      );

      expect(snapData.canRevert, isTrue);
    });

    test('canRevert returns false for uninstalled snaps', () {
      final storeSnap = createSnap(name: 'test', version: '1.0.0');
      final snapData = SnapData(
        name: 'test',
        localSnap: null,
        storeSnap: storeSnap,
      );

      expect(snapData.canRevert, isFalse);
    });

    test(
        'canRevert returns true for installed snaps with store data and previous local revision',
        () {
      final localSnap = createSnap(name: 'test', version: '2.0.0');
      final storeSnap = createSnap(name: 'test', version: '1.0.0');
      final snapData = SnapData(
        name: 'test',
        localSnap: localSnap,
        storeSnap: storeSnap,
        hasPreviousLocalRevision: true,
      );

      expect(snapData.canRevert, isTrue);
    });

    test('isInstalled returns true for installed snaps', () {
      final localSnap = createSnap(name: 'test', version: '1.0.0');
      final snapData = SnapData(
        name: 'test',
        localSnap: localSnap,
        storeSnap: null,
      );

      expect(snapData.isInstalled, isTrue);
    });

    test('isInstalled returns false for uninstalled snaps', () {
      final storeSnap = createSnap(name: 'test', version: '1.0.0');
      final snapData = SnapData(
        name: 'test',
        localSnap: null,
        storeSnap: storeSnap,
      );

      expect(snapData.isInstalled, isFalse);
    });
  });
}
