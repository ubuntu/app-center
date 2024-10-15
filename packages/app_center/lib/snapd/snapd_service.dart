import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/snapd/snapd_watcher.dart';
import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

class SnapdService extends SnapdClient with SnapdCache, SnapdWatcher {
  Future<void> waitChange(String changeId) =>
      watchChange(changeId).firstWhere((change) => change.ready);

  Future<Snap?> findById(String snapId) async {
    final queryParams = {
      'series': '16',
      'remote': 'true',
      'snap-id': snapId,
    };
    final result =
        await getAssertions(assertion: 'snap-declaration', params: queryParams);
    final declaration = SnapDeclaration.fromJson(result);
    final findResult = await find(name: declaration.snapName);
    return findResult
        .singleWhereOrNull((element) => element.id == declaration.snapId);
  }
}
