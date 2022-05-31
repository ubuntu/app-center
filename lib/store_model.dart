import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class StoreModel extends SafeChangeNotifier {
  final Connectivity _connectivity;
  StreamSubscription? _sub;
  ConnectivityResult? _state;

  StoreModel(this._connectivity);
  ConnectivityResult? get state => _state;

  Future<void> refresh() {
    return _connectivity.checkConnectivity().then((state) {
      _state = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get appIsOnline =>
      _state == ConnectivityResult.ethernet ||
      _state == ConnectivityResult.wifi;

  Future<void> init() async {
    _sub = _connectivity.onConnectivityChanged.listen((state) {
      _state = state;
      notifyListeners();
    });
    return refresh();
  }
}
