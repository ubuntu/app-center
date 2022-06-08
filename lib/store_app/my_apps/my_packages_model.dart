import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class MyPackagesModel extends SafeChangeNotifier {
  final PackageKitClient _client;

  MyPackagesModel(this._client) : _packageIds = {};

  final Set<PackageKitPackageId> _packageIds;
  List<PackageKitPackageId> get packages => _packageIds.toList();

  Future<void> init() async {
    await getPackages();
    notifyListeners();
  }

  Future<void> getPackages() async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((packageKitEvent) {
      if (packageKitEvent is PackageKitPackageEvent) {
        final id = packageKitEvent.packageId;
        _packageIds.add(id);
      } else if (packageKitEvent is PackageKitErrorCodeEvent) {
      } else if (packageKitEvent is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getPackages(
      filter: {PackageKitFilter.installed, PackageKitFilter.application},
    );
    await completer.future;
  }
}
