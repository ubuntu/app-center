import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';

class MySnapsModel extends SafeChangeNotifier {
  final SnapdClient _client;
  final AppChangeService _appChangeService;
  StreamSubscription<bool>? _snapChangesSub;
  final List<Snap> _localSnaps;
  List<Snap> get localSnaps => _localSnaps;

  MySnapsModel(
    this._client,
    this._appChangeService,
  ) : _localSnaps = [];

  Future<void> init() async {
    await _loadLocalSnaps();
    _snapChangesSub = _appChangeService.snapChangesInserted.listen((_) {
      if (_appChangeService.snapChanges.isEmpty) {
        _loadLocalSnaps().then((value) => notifyListeners());
      }
    });
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalSnaps() async {
    await _client.loadAuthorization();
    final snaps = (await _client.getSnaps())
        .where(
          (snap) => _appChangeService.getChange(snap) == null,
        )
        .toList();
    snaps.sort((a, b) => a.name.compareTo(b.name));
    _localSnaps.clear();
    _localSnaps.addAll(snaps);
  }
}
