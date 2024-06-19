import 'package:app_center/manage/manage_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  test('no updates available', () async {
    final snapd = registerMockSnapdService(
      installedSnaps: const [Snap(name: 'firefox'), Snap(name: 'thunderbird')],
    );
    final updatesModel = createMockUpdatesModel();
    final model = ManageModel(snapd: snapd, updatesModel: updatesModel);
    await model.init();

    expect(model.nonRefreshableSnaps,
        equals(const [Snap(name: 'firefox'), Snap(name: 'thunderbird')]));
    expect(model.refreshableSnaps, isEmpty);
  });
  test('update available', () async {
    final snapd = registerMockSnapdService(
      installedSnaps: const [Snap(name: 'firefox'), Snap(name: 'thunderbird')],
    );
    final updatesModel =
        createMockUpdatesModel(refreshableSnapNames: ['firefox']);
    final model = ManageModel(snapd: snapd, updatesModel: updatesModel);
    await model.init();

    expect(
        model.nonRefreshableSnaps, equals(const [Snap(name: 'thunderbird')]));
    expect(model.refreshableSnaps, equals(const [Snap(name: 'firefox')]));
  });
}
