import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/snapd/snapd_watcher.dart';
import 'package:snapd/snapd.dart';

class SnapdService extends SnapdClient with SnapdCache, SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);

  /// Returns true if there exists a non-active local revision that is older
  /// than the currently active revision. This matches snapd's notion of
  /// "previous" for the revert command.
  Future<bool> hasPreviousRevision(String name) async {
    final revisions = await getLocalRevisions(name);
    int? activeRev;
    for (final r in revisions) {
      if (r.active) {
        activeRev = r.revision;
        break;
      }
    }
    if (activeRev == null) return false;
    for (final r in revisions) {
      if (!r.active && r.revision < activeRev) {
        return true;
      }
    }
    return false;
  }

  /// Reverts the snap with the given [name] to its previous version.
  /// Returns the change ID for this operation, use [getChange] to get the
  /// status of this operation.
  Future<String> revert(String name) => revertSnap(name);
}
