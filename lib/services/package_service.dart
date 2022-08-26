import 'dart:async';
import 'dart:io';

import 'package:packagekit/packagekit.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:window_manager/window_manager.dart';

class PackageService {
  final PackageKitClient _client;
  PackageService() : _client = getService<PackageKitClient>() {
    _client.connect();
  }

  final Map<PackageKitPackageId, bool> _updates = {};
  List<PackageKitPackageId> get updates =>
      _updates.entries.map((e) => e.key).toList();
  PackageKitPackageId getUpdate(int index) =>
      _updates.entries.elementAt(index).key;
  final _updatesChangedController = StreamController<bool>.broadcast();
  Stream<bool> get updatesChanged => _updatesChangedController.stream;
  void setUpdatesChanged(bool value) {
    _updatesChangedController.add(value);
  }

  final Map<String, PackageKitPackageId> _installedPackages = {};
  PackageKitPackageId? getInstalledId(String name) => _installedPackages[name];
  final _installedPackagesController = StreamController<bool>.broadcast();
  Stream<bool> get installedPackagesChanged =>
      _installedPackagesController.stream;
  void setInstalledPackagesChanged(bool value) {
    _installedPackagesController.add(value);
  }

  final Map<PackageKitPackageId, PackageKitGroup> _idsToGroups = {};
  final _groupsController = StreamController<bool>.broadcast();
  Stream<bool> get groupsChanged => _groupsController.stream;
  void setGroupsChanged(bool value) {
    _groupsController.add(value);
  }

  final List<PackageKitRepositoryDetailEvent> _repos = [];
  List<PackageKitRepositoryDetailEvent> get repos => _repos;
  final _reposChangedController = StreamController<bool>.broadcast();
  Stream<bool> get reposChanged => _reposChangedController.stream;
  void setReposChanged(bool value) {
    _reposChangedController.add(value);
  }

  PackageKitGroup? getGroup(PackageKitPackageId id) {
    return _idsToGroups[id];
  }

  final _requireRestartController = StreamController<bool>.broadcast();
  Stream<bool> get requireRestart => _requireRestartController.stream;
  void setRequireRestart(bool value) {
    _requireRestartController.add(value);
  }

  final _percentageController = StreamController<int?>.broadcast();
  Stream<int?> get percentage => _percentageController.stream;
  void setPercentage(int? value) {
    _percentageController.add(value);
  }

  final _processedIdController =
      StreamController<PackageKitPackageId?>.broadcast();
  Stream<PackageKitPackageId?> get processedId => _processedIdController.stream;
  void setProcessedId(PackageKitPackageId? value) {
    _processedIdController.add(value);
  }

  final _errorMessageController = StreamController<String>.broadcast();
  Stream<String> get errorMessage => _errorMessageController.stream;
  void setErrorMessage(String value) {
    _errorMessageController.add(value);
  }

  final _manualRepoNameController = StreamController<String>.broadcast();
  Stream<String> get manualRepoName => _manualRepoNameController.stream;
  void setManualRepoName(String value) {
    _manualRepoNameController.add(value);
  }

  final _updatesStateController = StreamController<UpdatesState>.broadcast();
  Stream<UpdatesState> get updatesState => _updatesStateController.stream;
  void setUpdatesState(UpdatesState value) {
    _updatesStateController.add(value);
  }

  final _infoController = StreamController<PackageKitInfo?>.broadcast();
  Stream<PackageKitInfo?> get info => _infoController.stream;
  void setInfo(PackageKitInfo? value) {
    _infoController.add(value);
  }

  final _statusController = StreamController<PackageKitStatus?>.broadcast();
  Stream<PackageKitStatus?> get status => _statusController.stream;
  void setStatus(PackageKitStatus? value) {
    _statusController.add(value);
  }

  final _selectionChangedController = StreamController<bool>.broadcast();
  Stream<bool> get selectionChanged => _selectionChangedController.stream;
  void selectAll() {
    for (final entry in _updates.entries) {
      _updates[entry.key] = true;
    }
    _selectionChangedController.add(true);
  }

  void deselectAll() {
    for (final entry in _updates.entries) {
      _updates[entry.key] = false;
    }
    _selectionChangedController.add(true);
  }

  bool get allSelected =>
      _updates.entries.where((e) => e.value).length == _updates.length;

  bool isUpdateSelected(PackageKitPackageId update) => _updates[update] == true;

  void selectUpdate(PackageKitPackageId id, bool value) {
    _updates[id] = value;
    _selectionChangedController.add(true);
  }

  bool? initialized;
  Future<void> init() async {
    setUpdatesState(UpdatesState.checkingForUpdates);
    await _getInstalledPackages();
    await _loadRepoList();
    refresh().then((value) => initialized = true);
  }

  Future<void> refresh() async {
    windowManager.setClosable(false);

    setErrorMessage('');
    setUpdatesState(UpdatesState.checkingForUpdates);
    await _refreshCache();
    await _getUpdates();
    setUpdatesState(
      _updates.isEmpty ? UpdatesState.noUpdates : UpdatesState.readyToUpdate,
    );
    windowManager.setClosable(true);
  }

  Future<void> _refreshCache() async {
    setErrorMessage('');
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitRepositoryDetailEvent) {
        // print(event.description);
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.refreshCache();
    await completer.future;
  }

  Future<void> _getUpdates({Set<PackageKitFilter> filter = const {}}) async {
    setErrorMessage('');
    _updates.clear();
    _idsToGroups.clear();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        final id = event.packageId;
        _updates.putIfAbsent(id, () => true);
        setUpdatesChanged(true);
      } else if (event is PackageKitItemProgressEvent) {
        setPercentage(event.percentage);
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getUpdates(filter: filter);
    await completer.future;
    for (var entry in _updates.entries) {
      if (!_idsToGroups.containsKey(entry.key)) {
        final PackageKitGroup group = await _getGroup(entry.key);
        _idsToGroups.putIfAbsent(entry.key, () => group);
        setGroupsChanged(true);
      }
    }
  }

  Future<void> updateAll() async {
    windowManager.setClosable(false);

    setErrorMessage('');
    final List<PackageKitPackageId> selectedUpdates = _updates.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
    if (selectedUpdates.isEmpty) return;
    final updatePackagesTransaction = await _client.createTransaction();
    final updatePackagesCompleter = Completer();
    setUpdatesState(UpdatesState.updating);
    updatePackagesTransaction.events.listen((event) {
      if (event is PackageKitRequireRestartEvent) {
        setRequireRestart(event.type == PackageKitRestart.system);
      }
      if (event is PackageKitPackageEvent) {
        setProcessedId(event.packageId);
        setInfo(event.info);
      } else if (event is PackageKitItemProgressEvent) {
        setPercentage(event.percentage);
        setProcessedId(event.packageId);
        setStatus(event.status);
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        updatePackagesCompleter.complete();
      }
    });
    await updatePackagesTransaction.updatePackages(selectedUpdates);
    await updatePackagesCompleter.future;
    _updates.clear();
    setInfo(null);
    setStatus(null);
    setProcessedId(null);
    setPercentage(null);
    setUpdatesState(UpdatesState.noUpdates);
    windowManager.setClosable(true);
  }

  Future<void> _getInstalledPackages() async {
    setErrorMessage('');
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        _installedPackages.putIfAbsent(
          event.packageId.name,
          () => event.packageId,
        );
        setInstalledPackagesChanged(true);
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
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

  Future<void> _loadRepoList() async {
    setErrorMessage('');
    _repos.clear();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitRepositoryDetailEvent) {
        _repos.add(event);
        setReposChanged(true);
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getRepositoryList();
    await completer.future;
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
    setReposChanged(true);
  }

  // Not implemented in packagekit.dart
  Future<void> addRepo(String manualRepoName) async {
    if (manualRepoName.isEmpty) return;
    Process.start(
      'pkexec',
      [
        'apt-add-repository',
        manualRepoName,
      ],
      mode: ProcessStartMode.detached,
    );
    setReposChanged(true);
  }

  void reboot() {
    Process.start(
      'reboot',
      [],
      mode: ProcessStartMode.detached,
    );
  }
}
