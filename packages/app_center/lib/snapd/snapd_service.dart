import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/snapd/snapd_watcher.dart';
import 'package:snapd/snapd.dart';

class SnapdService extends SnapdClient with SnapdCache, SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);
}
