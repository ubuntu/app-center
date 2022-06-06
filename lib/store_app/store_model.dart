import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class StoreModel extends SafeChangeNotifier {
  final AppChangeService _appChangeService;
  StreamSubscription<bool>? _snapChangesSub;

  StoreModel() : _appChangeService = getService<AppChangeService>();

  Future<void> init() async {
    _snapChangesSub = _appChangeService.snapChangesInserted.listen((_) {
      notifyListeners();
    });
  }

  Map<Snap, SnapdChange> get snapChanges => _appChangeService.snapChanges;

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }
}
