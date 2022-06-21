import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class SystemUpdatesModel extends SafeChangeNotifier {
  final PackageKitClient _client;

  final List<PackageKitPackageId> updates = [];
  String errorString = '';
  bool updating = false;

  SystemUpdatesModel(this._client);

  Future<void> getUpdates() async {
    errorString = '';
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        final id = event.packageId;
        updates.add(id);
      } else if (event is PackageKitErrorCodeEvent) {
        errorString = '${event.code}: ${event.details}';
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
      notifyListeners();
    });
    await transaction.getUpdates();
    await completer.future;
    notifyListeners();
  }

  Future<void> updateAll() async {
    if (updates.isEmpty) return;
    final updatePackagesTransaction = await _client.createTransaction();
    final updatePackagesCompleter = Completer();
    updating = true;
    updatePackagesTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        // print('[${event.packageId.name}] ${event.info}');
      } else if (event is PackageKitItemProgressEvent) {
        // print('[${event.packageId.name}] ${event.status} ${event.percentage}%');
      } else if (event is PackageKitErrorCodeEvent) {
        // print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        updatePackagesCompleter.complete();
        updating = false;
      }
      notifyListeners();
    });
    await updatePackagesTransaction.updatePackages(updates);
    await updatePackagesCompleter.future;
    notifyListeners();
  }

  final List<PackageKitRepositoryDetailEvent> repos = [];
  Future<void> loadRepoList() async {
    repos.clear();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitRepositoryDetailEvent) {
        repos.add(event);
        // print(
        // '${event.enabled ? 'Enabled ' : 'Disabled'} ${event.repoId} ${event.description}');
      } else if (event is PackageKitErrorCodeEvent) {
        // print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
      notifyListeners();
    });
    await transaction.getRepositoryList();
    await completer.future;
    notifyListeners();
  }

  Future<void> toggleRepo({required String id, required bool value}) async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      // print(event);
      if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.setRepositoryEnabled(id, value);
    await completer.future;
    loadRepoList();
  }

  // Not implemented in packagekit.dart
  Future<void> addRepo(String id) async {}
  // Not implemented in packagekit.dart
  Future<void> removeRepo(String id) async {}
}
