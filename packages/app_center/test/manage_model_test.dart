import 'package:app_center/manage/manage_model.dart';
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
    final model = await container.read(manageModelProvider.future);

    expect(
      model.nonRefreshableSnaps,
      equals([createSnap(name: 'firefox'), createSnap(name: 'thunderbird')]),
    );
    expect(model.refreshableSnaps, isEmpty);
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
    final model = await container.read(manageModelProvider.future);

    expect(
      model.nonRefreshableSnaps,
      equals([createSnap(name: 'thunderbird')]),
    );
    expect(
      model.refreshableSnaps,
      equals([createSnap(name: 'firefox')]),
    );
  });
}
