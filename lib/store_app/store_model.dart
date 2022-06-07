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
  StreamSubscription? _connectivitySub;
  ConnectivityResult? _connectivityResult;
  ConnectivityResult? get state => _connectivityResult;

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
    _connectivitySub?.cancel();

    super.dispose();
  }

  Future<void> refreshConnectivity() {
    return _connectivity.checkConnectivity().then((state) {
      _connectivityResult = state;
      notifyListeners();
    });
  }

  bool get appIsOnline =>
      _connectivityResult == ConnectivityResult.ethernet ||
      _connectivityResult == ConnectivityResult.wifi;

  Future<void> initConnectivity() async {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      _connectivityResult = result;

      notifyListeners();
    });
    return refreshConnectivity();
  }
}
