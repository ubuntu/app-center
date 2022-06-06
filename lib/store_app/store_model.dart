import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class StoreModel extends SafeChangeNotifier {
  final AppChangeService _appChangeService;
  StreamSubscription<bool>? _snapChangesSub;
  final Connectivity _connectivity;
  StreamSubscription? _sub;
  ConnectivityResult? _result;
  ConnectivityResult? get state => _result;

  StoreModel(this._connectivity)
      : _appChangeService = getService<AppChangeService>();

  Future<void> init() async {
    _snapChangesSub = _appChangeService.snapChangesInserted.listen((_) {
      notifyListeners();
    });
    initConnectivity();
  }

  Map<Snap, SnapdChange> get snapChanges => _appChangeService.snapChanges;

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    _sub?.cancel();

    super.dispose();
  }

  Future<void> refreshConnectivity() {
    return _connectivity.checkConnectivity().then((state) {
      _result = state;
      notifyListeners();
    });
  }

  bool get appIsOnline =>
      _result == ConnectivityResult.ethernet ||
      _result == ConnectivityResult.wifi;

  Future<void> initConnectivity() async {
    _sub = _connectivity.onConnectivityChanged.listen((result) {
      _result = result;

      notifyListeners();
    });
    return refreshConnectivity();
  }
}
