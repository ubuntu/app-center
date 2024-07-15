import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final refreshableSnaps = await container.read(updatesModelProvider.future);

    expect(
      nonRefreshableSnaps,
      equals([createSnap(name: 'firefox'), createSnap(name: 'thunderbird')]),
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
    container.read(showLocalSystemAppsProvider.notifier).state = true;
    final nonRefreshableSnaps =
        await container.read(filteredLocalSnapsProvider.future);
    final refreshableSnaps = await container.read(updatesModelProvider.future);

    expect(
      nonRefreshableSnaps,
      equals([createSnap(name: 'thunderbird')]),
    );
    expect(
      refreshableSnaps,
      equals([createSnap(name: 'firefox')]),
    );
  });
}
