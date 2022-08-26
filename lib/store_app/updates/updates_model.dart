import 'dart:async';
import 'dart:io';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/updates_state.dart';

class UpdatesModel extends SafeChangeNotifier {
  final PackageKitClient _client;

  final Map<PackageKitPackageId, bool> updates = {};
  PackageKitPackageId getUpdate(int index) =>
      updates.entries.elementAt(index).key;

  final Map<String, PackageKitPackageId> installedPackages = {};

  final Map<PackageKitPackageId, PackageKitGroup> idsToGroups = {};

  bool _requireRestart;
  bool get requireRestart => _requireRestart;
  set requireRestart(bool value) {
    if (value == _requireRestart) return;
    _requireRestart = value;
    notifyListeners();
  }

  int? _percentage;
  int? get percentage => _percentage;
  set percentage(int? value) {
    if (value == _percentage) return;
    _percentage = value;
    notifyListeners();
  }

  PackageKitPackageId? _processedId;
  PackageKitPackageId? get processedId => _processedId;
  set processedId(PackageKitPackageId? value) {
    if (value == _processedId) return;
    _processedId = value;
    notifyListeners();
  }

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

  String _errorString = '';
  String get errorString => _errorString;
  set errorString(String value) {
    if (value == _errorString) return;
    _errorString = value;
    notifyListeners();
  }

  String _manualRepoName = '';
  set manualRepoName(String value) {
    if (value == _manualRepoName) return;
    _manualRepoName = value;
    notifyListeners();
  }

  UpdatesState _updatesState;
  UpdatesState get updatesState => _updatesState;
  set updatesState(UpdatesState value) {
    if (value == _updatesState) return;
    _updatesState = value;
    notifyListeners();
  }

  UpdatesModel(this._client)
      : _requireRestart = false,
        _updatesState = UpdatesState.checkingForUpdates {
    _client.connect();
  }

  void init() async {
    await _getInstalledPackages();
    await refresh();
    await _loadRepoList();

    notifyListeners();
  }

  Future<void> refresh() async {
    updatesState = UpdatesState.checkingForUpdates;
    await _refreshCache();
    await _getUpdates();
    updatesState =
        updates.isEmpty ? UpdatesState.noUpdates : UpdatesState.readyToUpdate;
  }

  Future<void> _refreshCache() async {
    updatesState = UpdatesState.checkingForUpdates;
    errorString = '';
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitRepositoryDetailEvent) {
        // print(event.description);
      } else if (event is PackageKitErrorCodeEvent) {
        errorString = '${event.code}: ${event.details}';
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.refreshCache();
    await completer.future;
  }

  Future<void> _getUpdates({Set<PackageKitFilter> filter = const {}}) async {
    updates.clear();
    idsToGroups.clear();
    errorString = '';
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        final id = event.packageId;
        updates.putIfAbsent(id, () => true);
      } else if (event is PackageKitItemProgressEvent) {
        percentage = event.percentage;
      } else if (event is PackageKitErrorCodeEvent) {
        errorString = '${event.code}: ${event.details}';
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getUpdates(filter: filter);
    await completer.future;
    for (var entry in updates.entries) {
      if (!idsToGroups.containsKey(entry.key)) {
        final PackageKitGroup group = await _getGroup(entry.key);
        idsToGroups.putIfAbsent(entry.key, () => group);
      }
    }
  }

  PackageKitInfo? _info;
  PackageKitInfo? get info => _info;
  set info(PackageKitInfo? value) {
    if (value == _info) return;
    _info = value;
    notifyListeners();
  }

  PackageKitStatus? _status;
  PackageKitStatus? get status => _status;
  set status(PackageKitStatus? value) {
    if (value == _status) return;
    _status = value;
    notifyListeners();
  }

  Future<void> updateAll() async {
    errorString = '';
    final List<PackageKitPackageId> selectedUpdates = updates.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
    if (selectedUpdates.isEmpty) return;
    final updatePackagesTransaction = await _client.createTransaction();
    final updatePackagesCompleter = Completer();
    updatesState = UpdatesState.updating;
    updatePackagesTransaction.events.listen((event) {
      if (event is PackageKitRequireRestartEvent) {
        requireRestart = event.type == PackageKitRestart.system;
      }
      if (event is PackageKitPackageEvent) {
        processedId = event.packageId;
        info = event.info;
      } else if (event is PackageKitItemProgressEvent) {
        percentage = event.percentage;
        processedId = event.packageId;
        status = event.status;
      } else if (event is PackageKitErrorCodeEvent) {
        errorString = '${event.code}: ${event.details}';
      } else if (event is PackageKitFinishedEvent) {
        updatePackagesCompleter.complete();
      }
    });
    await updatePackagesTransaction.updatePackages(selectedUpdates);
    await updatePackagesCompleter.future;
    updates.clear();
    info = null;
    status = null;
    processedId = null;
    percentage = null;
    updatesState = UpdatesState.noUpdates;
  }

  final List<PackageKitRepositoryDetailEvent> repos = [];
  Future<void> _loadRepoList() async {
    errorString = '';
    repos.clear();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitRepositoryDetailEvent) {
        repos.add(event);
      } else if (event is PackageKitErrorCodeEvent) {
        errorString = '${event.code}: ${event.details}';
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getRepositoryList();
    await completer.future;
    notifyListeners();
  }

  Future<void> toggleRepo({required String id, required bool value}) async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.setRepositoryEnabled(id, value);
    await completer.future;
    _loadRepoList();
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
    _loadRepoList();
  }

  // Not implemented in packagekit.dart and too hard for apt-add-repository
  Future<void> removeRepo(String id) async {}

  void reboot() {
    Process.start(
      'reboot',
      [],
      mode: ProcessStartMode.detached,
    );
  }

  Future<void> _getInstalledPackages() async {
    errorString = '';
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        installedPackages.putIfAbsent(
          event.packageId.name,
          () => event.packageId,
        );
      } else if (event is PackageKitErrorCodeEvent) {
        errorString = '${event.code}: ${event.details}';
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getPackages(
      filter: {PackageKitFilter.installed},
    );
    await completer.future;
  }

  Future<PackageKitGroup> _getGroup(PackageKitPackageId id) async {
    final installTransaction = await _client.createTransaction();
    final detailsCompleter = Completer();
    PackageKitGroup? group;
    installTransaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        group = event.group;
      } else if (event is PackageKitFinishedEvent) {
        detailsCompleter.complete();
      }
    });
    await installTransaction.getDetails([id]);
    await detailsCompleter.future;
    return group ?? PackageKitGroup.unknown;
  }
}
