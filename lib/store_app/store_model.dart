import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';

class StoreModel extends SafeChangeNotifier {
  StoreModel(this._connectivity, this._appChangeService);

  final AppChangeService _appChangeService;
  Map<Snap, SnapdChange> get snapChanges => _appChangeService.snapChanges;
  StreamSubscription<bool>? _snapChangesSub;

  final Connectivity _connectivity;
  StreamSubscription? _connectivitySub;
  ConnectivityResult? _connectivityResult = ConnectivityResult.wifi;
  ConnectivityResult? get state => _connectivityResult;

  Future<void> init() async {
    _snapChangesSub = _appChangeService.snapChangesInserted.listen((_) {
      notifyListeners();
    });
    initConnectivity();
  }

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
