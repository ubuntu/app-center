import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/services/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class MyPackagesModel extends SafeChangeNotifier {
  final PackageService _service;
  MyPackagesModel() : _service = getService<PackageService>();

  StreamSubscription<bool>? _installedSub;

  List<PackageKitPackageId> get packages => _service.installedPackages;

  void init() async {
    _installedSub = _service.installedPackagesChanged.listen((event) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _installedSub?.cancel();
    super.dispose();
  }
}
