import 'package:snapd/snapd.dart';

import 'snapd_watcher.dart';

class SnapdService extends SnapdClient with SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);
}
