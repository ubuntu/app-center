import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/package_state.dart';
import 'package:software/store_app/common/utils.dart';
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
  List<PackageKitPackageId> get installedPackages =>
      _installedPackages.entries.map((e) => e.value).toList();
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

  final _updatesPercentageController = StreamController<int?>.broadcast();
  Stream<int?> get updatesPercentage => _updatesPercentageController.stream;
  void setUpdatePercentage(int? value) {
    _updatesPercentageController.add(value);
  }

  final _packagePercentageController = StreamController<int?>.broadcast();
  Stream<int?> get packagePercentage => _packagePercentageController.stream;
  void setPackagePercentage(int? value) {
    _updatesPercentageController.add(value);
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

  final _packageStateController = StreamController<PackageState>.broadcast();
  Stream<PackageState> get packageState => _packageStateController.stream;
  void setPackageState(PackageState value) {
    _packageStateController.add(value);
  }

  final _summaryController = StreamController<String>.broadcast();
  Stream<String> get summary => _summaryController.stream;
  void setSummary(String value) {
    _summaryController.add(value);
  }

  final _urlController = StreamController<String>.broadcast();
  Stream<String> get url => _urlController.stream;
  void setUrl(String value) {
    _urlController.add(value);
  }

  final _licenseController = StreamController<String>.broadcast();
  Stream<String> get license => _licenseController.stream;
  void setLicense(String value) {
    _licenseController.add(value);
  }

  final _sizeController = StreamController<String>.broadcast();
  Stream<String> get size => _sizeController.stream;
  void setSize(int value) {
    _sizeController.add(formatBytes(value, 2));
  }

  final _descriptionController = StreamController<String>.broadcast();
  Stream<String> get description => _descriptionController.stream;
  void setDescription(String value) {
    _descriptionController.add(value);
  }

  final _changelogController = StreamController<String>.broadcast();
  Stream<String> get changelog => _changelogController.stream;
  void setChangelog(String value) {
    _changelogController.add(value);
  }

  final _issuedController = StreamController<String>.broadcast();
  Stream<String> get issued => _issuedController.stream;
  void setIssued(String value) {
    _issuedController.add(value);
  }

  final _groupController = StreamController<PackageKitGroup>.broadcast();
  Stream<PackageKitGroup> get group => _groupController.stream;
  void setGroup(PackageKitGroup value) {
    _groupController.add(value);
  }

  final _isInstalledController = StreamController<bool>.broadcast();
  Stream<bool> get isInstalled => _isInstalledController.stream;
  void setIsInstalled(bool value) {
    _isInstalledController.add(value);
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
    try {
      setErrorMessage('');
      setUpdatesState(UpdatesState.checkingForUpdates);
      await _refreshCache();
      await _getUpdates();
      setUpdatesState(
        _updates.isEmpty ? UpdatesState.noUpdates : UpdatesState.readyToUpdate,
      );
    } finally {
      windowManager.setClosable(true);
    }
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
        setUpdatePercentage(event.percentage);
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
    try {
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
          setUpdatePercentage(event.percentage);
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
      setUpdatePercentage(null);
      setUpdatesState(UpdatesState.noUpdates);
    } finally {
      windowManager.setClosable(true);
    }
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

  /// Removes with package with [packageId]
  Future<void> remove({required PackageKitPackageId packageId}) async {
    final removeTransaction = await _client.createTransaction();
    setPackageState(PackageState.removing);
    final removeCompleter = Completer();
    removeTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
      } else if (event is PackageKitItemProgressEvent) {
        setPackagePercentage(event.percentage);
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        removeCompleter.complete();
      }
    });
    await removeTransaction.removePackages([packageId]);
    await removeCompleter.future;
    await isIdInstalled(id: packageId);
    setPackageState(PackageState.ready);
  }

  /// Installs with package with [packageId]
  Future<void> install({required PackageKitPackageId packageId}) async {
    final installTransaction = await _client.createTransaction();
    setPackageState(PackageState.installing);
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
      } else if (event is PackageKitItemProgressEvent) {
        setPackagePercentage(event.percentage);
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
      }
    });
    await installTransaction.installPackages([packageId]);
    await installCompleter.future;
    await isIdInstalled(id: packageId);

    setPackageState(PackageState.ready);
  }

  /// Check if an app with given [packageId] is installed.
  Future<void> isIdInstalled({required PackageKitPackageId id}) async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        if (event.info == PackageKitInfo.installed) {
          setIsInstalled(true);
        } else {
          setIsInstalled(false);
        }
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });

    await transaction
        .searchNames([id.name], filter: {PackageKitFilter.installed});
    await completer.future;
  }

  /// Get the details about the package or update with given [packageId]
  Future<void> getDetails({required PackageKitPackageId packageId}) async {
    var installTransaction = await _client.createTransaction();
    var detailsCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        setSummary(event.summary);
        setUrl(event.url);
        setLicense(event.license);
        setSize(event.size);
        setDescription(event.description);
        setGroup(event.group);
      } else if (event is PackageKitFinishedEvent) {
        detailsCompleter.complete();
      }
    });
    await installTransaction.getDetails([packageId]);
    await detailsCompleter.future;
  }

  /// Get more details about given [packageId]
  Future<void> getUpdateDetail({
    required PackageKitPackageId packageId,
  }) async {
    setChangelog('');
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitUpdateDetailEvent) {
        setChangelog(event.changelog);
        setIssued(
          DateFormat.yMMMMEEEEd(Platform.localeName)
              .format(event.issued ?? DateTime.now()),
        );
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getUpdateDetail([packageId]);
    await completer.future;
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
