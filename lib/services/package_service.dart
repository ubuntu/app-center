/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';
import 'dart:io';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:intl/intl.dart';
import 'package:packagekit/packagekit.dart';
import 'package:synchronized/extension.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../package_state.dart';
import '../store_app/common/packagekit/package_model.dart';
import '../updates_state.dart';

class MissingPackageIDException implements Exception {
  const MissingPackageIDException();

  @override
  String toString() => 'Missing package ID';
}

class PackageService {
  PackageService()
      : _client = getService<PackageKitClient>(),
        _notificationsClient = getService<NotificationsClient>() {
    _client.connect();
  }

  final PackageKitClient _client;
  final NotificationsClient _notificationsClient;

  final _terminalOutputController = StreamController<String>.broadcast();
  Stream<String> get terminalOutput => _terminalOutputController.stream;
  void setTerminalOutput(String value) {
    _terminalOutputController.add(value);
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

  PackageKitRestart? lastRequireRestart;
  final _requireRestartController =
      StreamController<PackageKitRestart>.broadcast();
  Stream<PackageKitRestart> get requireRestart =>
      _requireRestartController.stream;
  void setRequireRestart(PackageKitRestart value) {
    _requireRestartController.add(value);
    lastRequireRestart = value;
  }

  int? lastUpdatesPercentage;
  final _updatesPercentageController = StreamController<int?>.broadcast();
  Stream<int?> get updatesPercentage => _updatesPercentageController.stream;
  void setUpdatePercentage(int? value) {
    _updatesPercentageController.add(value);
    lastUpdatesPercentage = value;
  }

  PackageKitPackageId? lastProcessedId;
  final _processedIdController =
      StreamController<PackageKitPackageId?>.broadcast();
  Stream<PackageKitPackageId?> get processedId => _processedIdController.stream;
  void setProcessedId(PackageKitPackageId? value) {
    _processedIdController.add(value);
    lastProcessedId = value;
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

  UpdatesState? lastUpdatesState;
  final _updatesStateController = StreamController<UpdatesState>.broadcast();
  Stream<UpdatesState> get updatesState => _updatesStateController.stream;
  void setUpdatesState(UpdatesState value) {
    _updatesStateController.add(value);
    lastUpdatesState = value;
  }

  PackageKitInfo? lastInfo;
  final _infoController = StreamController<PackageKitInfo?>.broadcast();
  Stream<PackageKitInfo?> get info => _infoController.stream;
  void setInfo(PackageKitInfo? value) {
    _infoController.add(value);
    lastInfo = value;
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
  bool get nothingSelected => _updates.entries
      .where((e) => e.value == true)
      .map((e) => e.key)
      .toList()
      .isEmpty;
  int get selectedUpdatesLength => _updates.entries
      .where((e) => e.value == true)
      .map((e) => e.key)
      .toList()
      .length;

  bool isUpdateSelected(PackageKitPackageId update) => _updates[update] == true;

  void selectUpdate(PackageKitPackageId id, bool value) {
    _updates[id] = value;
    _selectionChangedController.add(true);
  }

  Future<void> init({Set<PackageKitFilter> filters = const {}}) async {
    setErrorMessage('');
    await getInstalledPackages(filters: filters);
    unawaited(refreshUpdates());
  }

  Future<void> refreshUpdates() async {
    setErrorMessage('');
    setUpdatesState(UpdatesState.checkingForUpdates);
    await _loadRepoList();
    await _refreshCache();
    await _getUpdates();
    setUpdatesState(
      _updates.isEmpty ? UpdatesState.noUpdates : UpdatesState.readyToUpdate,
    );
  }

  void sendUpdateNotification({required String updatesAvailable}) {
    if (lastUpdatesState == UpdatesState.readyToUpdate) {
      _notificationsClient.notify(
        'Ubuntu Software',
        body: updatesAvailable,
        appName: 'snap-store',
        appIcon: 'snap-store',
        hints: [
          NotificationHint.desktopEntry('snap-store'),
          NotificationHint.urgency(NotificationUrgency.normal),
        ],
      );
    }
  }

  Future<void> _refreshCache() async {
    setErrorMessage('');
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitRepositoryDetailEvent) {
        // print(event.description);
      } else if (event is PackageKitErrorCodeEvent) {
        if (isRefreshErrorToReport(event.code)) {
          final error = '${event.code}: ${event.details}';
          setErrorMessage(error);
        }
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.refreshCache();
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> _getUpdates({Set<PackageKitFilter> filter = const {}}) async {
    setErrorMessage('');
    _updates.clear();
    _idsToGroups.clear();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        final id = event.packageId;
        _updates.putIfAbsent(id, () => true);
        setUpdatesChanged(true);
      } else if (event is PackageKitItemProgressEvent) {
        setUpdatePercentage(event.percentage);
      } else if (event is PackageKitErrorCodeEvent) {
        if (isRefreshErrorToReport(event.code)) {
          final error = '${event.code}: ${event.details}';
          setErrorMessage(error);
        }
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getUpdates(filter: filter);
    await completer.future.whenComplete(subscription.cancel);
    for (final entry in _updates.entries) {
      if (!_idsToGroups.containsKey(entry.key)) {
        final group = await _getGroup(entry.key);
        _idsToGroups.putIfAbsent(entry.key, () => group);
        setGroupsChanged(true);
      }
    }
  }

  Future<void> updateAll({
    required String updatesComplete,
    required String updatesAvailable,
  }) async {
    setErrorMessage('');
    final selectedUpdates = _updates.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
    if (selectedUpdates.isEmpty) return;
    var canceled = false;
    final updatePackagesTransaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = updatePackagesTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        setProcessedId(event.packageId);
        setInfo(event.info);
        setTerminalOutput(event.packageId.toString());
        setTerminalOutput(event.info.toString());
      } else if (event is PackageKitItemProgressEvent) {
        setUpdatesState(UpdatesState.updating);
        setUpdatePercentage(event.percentage);
        setProcessedId(event.packageId);
        setStatus(event.status);

        setTerminalOutput(event.percentage.toString());
        setTerminalOutput(event.packageId.toString());
        setTerminalOutput(event.status.toString());
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      } else if (event is PackageKitRequireRestartEvent) {
        setRequireRestart(event.type);
      } else if (event is PackageKitErrorCodeEvent) {
        if (event.code == PackageKitError.notAuthorized) {
          canceled = true;
        }
        if (isUpdateErrorToReport(event.code)) {
          final error = '${event.code}: ${event.details}';
          setErrorMessage(error);
          setTerminalOutput(error);
        }
      }
    });
    await updatePackagesTransaction.updatePackages(selectedUpdates);
    await completer.future.whenComplete(subscription.cancel);

    if (!canceled) {
      _updates.clear();
      setInfo(null);
      setStatus(null);
      setProcessedId(null);
      setUpdatePercentage(null);

      await refreshUpdates();

      if (updates.isEmpty) {
        setUpdatesState(UpdatesState.noUpdates);
        _notifyUpdatesComplete(updatesComplete);
      }
    }
  }

  void _notifyUpdatesComplete(String updatesComplete) {
    _notificationsClient.notify(
      'Ubuntu Software',
      body: updatesComplete,
      appName: 'snap-store',
      appIcon: 'snap-store',
      hints: [
        NotificationHint.desktopEntry('snap-store'),
        NotificationHint.urgency(NotificationUrgency.normal)
      ],
    );
  }

  Future<void> getInstalledPackages({
    Set<PackageKitFilter> filters = const {
      PackageKitFilter.installed,
    },
  }) async {
    _installedPackages.clear();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
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
      filter: filters,
    );
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<PackageKitGroup> _getGroup(PackageKitPackageId id) async {
    final installTransaction = await _client.createTransaction();
    final completer = Completer();
    PackageKitGroup? group;
    final subscription = installTransaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        group = event.group;
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await installTransaction.getDetails([id]);
    await completer.future.whenComplete(subscription.cancel);
    return group ?? PackageKitGroup.unknown;
  }

  Future<void> remove({required PackageModel model}) async {
    if (model.packageId == null) throw const MissingPackageIDException();
    model.packageState = PackageState.processing;
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        model.info = event.info;
      } else if (event is PackageKitItemProgressEvent) {
        model.percentage = 100 - event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        model.isInstalled = event.exit != PackageKitExit.success;
        model.packageState = PackageState.ready;
        completer.complete();
      }
    });
    unawaited(transaction.removePackages([model.packageId!]));
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> install({required PackageModel model}) async {
    if (model.packageId == null) throw const MissingPackageIDException();
    model.packageState = PackageState.processing;
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        model.info = event.info;
      } else if (event is PackageKitItemProgressEvent) {
        model.percentage = event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        model.packageState = PackageState.ready;
        model.isInstalled = event.exit == PackageKitExit.success;
        completer.complete();
      }
    });
    unawaited(transaction.installPackages([model.packageId!]));
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> isInstalled({required PackageModel model}) async {
    if (model.packageId == null) throw const MissingPackageIDException();
    model.packageState = PackageState.processing;
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        model.isInstalled = event.info == PackageKitInfo.installed;
      } else if (event is PackageKitFinishedEvent) {
        model.isInstalled ??= false;
        model.packageState = PackageState.ready;
        completer.complete();
      }
    });
    unawaited(transaction.searchNames(
      [model.packageId!.name],
      filter: {PackageKitFilter.installed},
    ));
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> getDetails({required PackageModel model}) async {
    if (model.packageId == null) throw const MissingPackageIDException();
    model.packageState = PackageState.processing;
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        model.summary = event.summary;
        model.url = event.url;
        model.license = event.license;
        model.size = event.size;
        model.group = event.group;
        model.description = event.description;
      } else if (event is PackageKitFinishedEvent) {
        model.packageState = PackageState.ready;
        completer.complete();
      }
    });
    unawaited(transaction.getDetails([model.packageId!]));
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> getUpdateDetail({
    required PackageModel model,
  }) async {
    if (model.packageId == null) throw const MissingPackageIDException();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitUpdateDetailEvent) {
        model.changelog = event.changelog;
        model.issued = DateFormat.yMMMMEEEEd(Platform.localeName)
            .format(event.issued ?? DateTime.now());
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getUpdateDetail([model.packageId!]);
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> _loadRepoList() async {
    setErrorMessage('');
    _repos.clear();
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
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
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> toggleRepo({required String id, required bool value}) async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    setUpdatesState(UpdatesState.checkingForUpdates);
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.setRepositoryEnabled(id, value);
    await completer.future.whenComplete(subscription.cancel);
    await _refreshCache();
    await _loadRepoList();
    setReposChanged(true);
    setUpdatesState(
      _updates.isEmpty ? UpdatesState.noUpdates : UpdatesState.readyToUpdate,
    );
  }

  // Not implemented in packagekit.dart
  Future<void> addRepo(String manualRepoName) async {
    if (manualRepoName.isEmpty) return;
    unawaited(
      Process.start(
        'pkexec',
        [
          'apt-add-repository',
          manualRepoName,
        ],
        mode: ProcessStartMode.detached,
      ),
    );
    setReposChanged(true);
  }

  Iterable<String>? _searchQuery;
  PackageKitTransaction? _searchTransaction;

  Future<List<PackageKitPackageId>> findPackageKitPackageIds({
    required Iterable<String> searchQuery,
    Set<PackageKitFilter> filter = const {},
  }) async {
    _searchQuery = searchQuery;
    if (searchQuery.isEmpty) return [];
    await _searchTransaction?.cancel();
    // ensure max one search transaction at a time
    return synchronized(() async {
      if (searchQuery != _searchQuery) return [];
      final ids = <PackageKitPackageId>[];
      final transaction = await _client.createTransaction();
      final completer = Completer();
      final subscription = transaction.events.listen((event) {
        if (event is PackageKitPackageEvent) {
          final id = event.packageId;
          ids.add(id);
        } else if (event is PackageKitErrorCodeEvent) {
        } else if (event is PackageKitFinishedEvent) {
          completer.complete();
        }
      });
      _searchTransaction = transaction;
      await transaction.searchNames(
        searchQuery,
        filter: filter,
      );
      await completer.future.whenComplete(subscription.cancel);
      _searchTransaction = null;

      return ids.take(20).toList();
    });
  }

  Future<void> getDetailsAboutLocalPackage({
    required PackageModel model,
    FileSystem fileSystem = const LocalFileSystem(),
  }) async {
    if (model.path == null ||
        model.path!.isEmpty ||
        !fileSystem.file(model.path!).existsSync()) {
      throw FileSystemException('', model.path);
    }
    model.packageState = PackageState.processing;
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        model.packageId = event.packageId;
        model.summary = event.summary;
        model.url = event.url;
        model.license = event.license;
        model.size = event.size;
        model.group = event.group;
        model.description = event.description;
      } else if (event is PackageKitFinishedEvent) {
        model.packageState = PackageState.ready;
        completer.complete();
      }
    });
    unawaited(transaction.getDetailsLocal([model.path!]));
    return completer.future.whenComplete(subscription.cancel);
  }

  Future<void> installLocalFile({
    required PackageModel model,
    FileSystem fileSystem = const LocalFileSystem(),
  }) async {
    if (model.path == null ||
        model.path!.isEmpty ||
        !fileSystem.file(model.path!).existsSync()) {
      throw FileSystemException('', model.path);
    }
    model.packageState = PackageState.processing;
    final transaction = await _client.createTransaction();
    final completer = Completer();
    final subscription = transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        model.info = event.info;
        model.packageId = event.packageId;
      } else if (event is PackageKitItemProgressEvent) {
        model.percentage = event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        model.isInstalled = event.exit == PackageKitExit.success;
        model.packageState = PackageState.ready;
        completer.complete();
      }
    });
    unawaited(transaction.installFiles([model.path!]));
    return completer.future.whenComplete(subscription.cancel);
  }

  bool isRefreshErrorToReport(PackageKitError code) {
    return !{
      PackageKitError.failedConfigParsing,
    }.contains(code);
  }

  bool isUpdateErrorToReport(PackageKitError code) {
    return !{
      PackageKitError.notAuthorized,
    }.contains(code);
  }

  Never exitApp() => exit(0);
}
