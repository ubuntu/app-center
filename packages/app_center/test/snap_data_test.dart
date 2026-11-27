import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

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
      },
    );

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
      },
    );

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

  group('defaultSelectedChannel', () {
    final channel = SnapChannel(releasedAt: DateTime(2026));
    final storeSnap = createSnap(
      tracks: ['18', '16'],
      channels: {'16/stable': channel, '18/stable': channel},
    );

    test('prefers the store default track', () {
      expect(SnapData.defaultSelectedChannel(null, storeSnap), '18/stable');
    });

    test('prefers the default track over latest/stable', () {
      final storeSnap = createSnap(
        tracks: ['16', 'latest'],
        channels: {'latest/stable': channel, '16/stable': channel},
      );

      expect(SnapData.defaultSelectedChannel(null, storeSnap), '16/stable');
    });

    test('keeps the tracked channel of an installed snap', () {
      final localSnap = createSnap(trackingChannel: '16/stable');

      expect(
        SnapData.defaultSelectedChannel(localSnap, storeSnap),
        '16/stable',
      );
    });

    test('expands abbreviated tracking channels', () {
      final storeSnap = createSnap(
        tracks: ['latest', '16'],
        channels: {
          'latest/stable': channel,
          'latest/beta': channel,
          '16/stable': channel,
        },
      );

      for (final (tracking, expected) in [
        ('beta', 'latest/beta'),
        ('16', '16/stable'),
      ]) {
        final localSnap = createSnap(trackingChannel: tracking);
        expect(
          SnapData.defaultSelectedChannel(localSnap, storeSnap),
          expected,
        );
      }
    });

    test('picks the lowest risk on the default track', () {
      final storeSnap = createSnap(
        tracks: ['latest', 'esr'],
        channels: {
          'esr/stable': channel,
          'latest/candidate': channel,
          'latest/edge': channel,
        },
      );

      expect(
        SnapData.defaultSelectedChannel(null, storeSnap),
        'latest/candidate',
      );
    });

    test('ignores tracks that only contain "stable" in their name', () {
      final storeSnap = createSnap(
        channels: {'unstable/edge': channel, '2/stable': channel},
      );

      expect(SnapData.defaultSelectedChannel(null, storeSnap), '2/stable');
    });
  });
}
