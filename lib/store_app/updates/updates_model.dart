import 'dart:async';
import 'dart:io';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class UpdatesModel extends SafeChangeNotifier {
  final PackageKitClient _client;

  final Map<PackageKitPackageId, bool> updates = {};

  int? percentage;
  PackageKitPackageId? currentId;

  void selectAll() {
    for (final entry in updates.entries) {
      updates[entry.key] = true;
      notifyListeners();
    }
  }

  void deselectAll() {
    for (final entry in updates.entries) {
      updates[entry.key] = false;
      notifyListeners();
    }
  }

  bool get allSelected =>
      updates.entries.where((e) => e.value).length == updates.length;

  void selectUpdate(PackageKitPackageId id, bool value) {
    updates[id] = value;
    notifyListeners();
  }

  String errorString = '';
  bool updating = false;
  String _manualRepoName = '';
  set manualRepoName(String value) {
    if (value == _manualRepoName) return;
    _manualRepoName = value;
    notifyListeners();
  }

  UpdatesModel(this._client) {
    _client.connect();
  }

  void init() {
    getUpdates();
    loadRepoList();
  }

  Future<void> refresh() async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    updating = true;
    transaction.events.listen((event) {
      if (event is PackageKitRepositoryDetailEvent) {
        // print(event.description);
      } else if (event is PackageKitErrorCodeEvent) {
        // print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.refreshCache();
    await completer.future;
    updating = false;
    notifyListeners();
  }

  Future<void> getUpdates() async {
    updates.clear();
    errorString = '';
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        final id = event.packageId;
        updates.putIfAbsent(id, () => true);
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
    final List<PackageKitPackageId> selectedUpdates = updates.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
    if (selectedUpdates.isEmpty) return;
    final updatePackagesTransaction = await _client.createTransaction();
    final updatePackagesCompleter = Completer();
    updating = true;
    updatePackagesTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        // print('[${event.packageId.name}] ${event.info}');
        currentId = event.packageId;
      } else if (event is PackageKitItemProgressEvent) {
        percentage = event.percentage;
        // print('[${event.packageId.name}] ${event.status} ${event.percentage}%');
      } else if (event is PackageKitErrorCodeEvent) {
        // print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        updatePackagesCompleter.complete();
        updating = false;
      }
      notifyListeners();
    });
    await updatePackagesTransaction.updatePackages(selectedUpdates);
    await updatePackagesCompleter.future;
    await getUpdates();
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
  Future<void> addRepo() async {
    if (_manualRepoName.isEmpty) return;
    Process.start(
      'pkexec',
      [
        'apt-add-repository',
        _manualRepoName,
      ],
      mode: ProcessStartMode.detached,
    );
    loadRepoList();
  }

  // Not implemented in packagekit.dart and too hard for apt-add-repository
  Future<void> removeRepo(String id) async {}
}
