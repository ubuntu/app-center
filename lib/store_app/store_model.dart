import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/snap_change_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class StoreModel extends SafeChangeNotifier {
  final SnapChangeService _snapChangeService;
  StreamSubscription<bool>? _snapChangesSub;

  StoreModel() : _snapChangeService = getService<SnapChangeService>();

  Future<void> init() async {
    _snapChangesSub = _snapChangeService.snapChangesInserted.listen((_) {
      notifyListeners();
    });
  }

  Map<Snap, SnapdChange> get snapChanges => _snapChangeService.snapChanges;

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }
}
