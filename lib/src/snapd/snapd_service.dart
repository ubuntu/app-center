import 'package:snapd/snapd.dart';

import 'snapd_cache.dart';
import 'snapd_watcher.dart';

class SnapdService extends SnapdClient with SnapdCache, SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);
}
