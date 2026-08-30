import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/snapd/snapd_watcher.dart';
import 'package:snapd/snapd.dart';

/// Local revision information for a snap
class LocalRevisionInfo {
  const LocalRevisionInfo({
    required this.revision,
    required this.version,
    required this.active,
  });

  final int revision;
  final String version;
  final bool active;
}

class SnapdService extends SnapdClient with SnapdCache, SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);

  /// Gets all local revisions for a snap using the snapd.dart library
  Future<List<LocalRevisionInfo>> getLocalRevisions(String name) async {
    try {
      // Use the existing getSnaps() method with SnapsFilter.all to get all local revisions
      final allSnaps = await getSnaps(filter: SnapsFilter.all);

      // Filter to only the snap we're interested in and convert to LocalRevisionInfo
      final revisions = allSnaps
          .where((snap) => snap.name == name)
          .map(
            (snap) => LocalRevisionInfo(
              revision: snap.revision,
              version: snap.version,
              active: snap.status == SnapStatus.active,
            ),
          )
          .toList();

      // Sort by revision descending (newest first)
      revisions.sort((a, b) => b.revision.compareTo(a.revision));

      return revisions;
    } on Object catch (_) {
      return [];
    }
  }

  /// Returns true if there exists a non-active local revision that is older
  /// than the currently active revision. This matches snapd's notion of
  /// "previous" for the revert command.
  Future<bool> hasPreviousRevision(String name) async {
    try {
      final revisions = await getLocalRevisions(name);
      if (revisions.isEmpty) return false;

      final activeRevision = revisions.firstWhere(
        (r) => r.active,
        orElse: () => revisions.first,
      );

      // Check if there's any non-active revision with a lower revision number
      return revisions.any(
        (r) => !r.active && r.revision < activeRevision.revision,
      );
    } on Object catch (_) {
      return false;
    }
  }

  /// Reverts the snap with the given [name] to its previous version.
  /// Returns the change ID for this operation, use [getChange] to get the
  /// status of this operation.
  Future<String> revert(String name) => revertSnap(name);
}
