import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/services/package_service.dart';

class MyPackagesModel extends SafeChangeNotifier {
  final PackageService _service;
  MyPackagesModel(this._service);

  StreamSubscription<bool>? _installedSub;

  List<PackageKitPackageId> get installedApps => _service.installedApps;

  void init() async {
    _installedSub = _service.installedAppsChanged.listen((event) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _installedSub?.cancel();
    super.dispose();
  }
}
