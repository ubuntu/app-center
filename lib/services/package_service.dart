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
import 'package:intl/intl.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/package_state.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/utils.dart';
import 'package:software/updates_state.dart';
import 'package:synchronized/extension.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class PackageService {
  final PackageKitClient _client;
  final NotificationsClient _notificationsClient;
  PackageService()
      : _client = getService<PackageKitClient>(),
        _notificationsClient = getService<NotificationsClient>() {
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

  final Map<String, PackageKitPackageId> _installedApps = {};
  List<PackageKitPackageId> get installedApps =>
      _installedApps.entries.map((e) => e.value).toList();
  PackageKitPackageId? getInstalledAppIds(String name) => _installedApps[name];
  final _installedAppsController = StreamController<bool>.broadcast();
  Stream<bool> get installedAppsChanged => _installedAppsController.stream;
  void setInstalledAppsChanged(bool value) {
    _installedAppsController.add(value);
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

  final _updatesPercentageController = StreamController<int?>.broadcast();
  Stream<int?> get updatesPercentage => _updatesPercentageController.stream;
  void setUpdatePercentage(int? value) {
    _updatesPercentageController.add(value);
  }

  final _packagePercentageController = StreamController<int?>.broadcast();
  Stream<int?> get packagePercentage => _packagePercentageController.stream;
  void setPackagePercentage(int? value) {
    _packagePercentageController.add(value);
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

  UpdatesState? lastUpdatesState;
  final _updatesStateController = StreamController<UpdatesState>.broadcast();
  Stream<UpdatesState> get updatesState => _updatesStateController.stream;
  void setUpdatesState(UpdatesState value) {
    _updatesStateController.add(value);
    lastUpdatesState = value;
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

  Timer? _refreshUpdatesTimer;

  Future<void> init({required String updatesAvailable}) async {
    setErrorMessage('');
    setPackageState(PackageState.processing);
    await _getInstalledPackages();
    await _getInstalledApps();
    setPackageState(PackageState.ready);
    refreshUpdates(updatesAvailable: updatesAvailable);
  }

  Future<void> refreshUpdates({required String updatesAvailable}) async {
    setErrorMessage('');
    setUpdatesState(UpdatesState.checkingForUpdates);
    await _loadRepoList();
    await _refreshCache();
    await _getUpdates();
    setUpdatesState(
      _updates.isEmpty ? UpdatesState.noUpdates : UpdatesState.readyToUpdate,
    );

    _refreshUpdatesTimer?.cancel();
    _refreshUpdatesTimer = Timer.periodic(
        const Duration(minutes: kCheckForUpdateTimeOutInMinutes), (timer) {
      if (lastUpdatesState == UpdatesState.noUpdates) {
        refreshUpdates(updatesAvailable: updatesAvailable);
      }
    });

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

  void dispose() {
    _refreshUpdatesTimer?.cancel();
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

  Future<void> updateAll({
    required String updatesComplete,
    required String updatesAvailable,
  }) async {
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
        setRequireRestart(event.type);
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
    if (selectedUpdates.length == updates.length) {
      setUpdatesState(UpdatesState.noUpdates);
    } else {
      await refreshUpdates(updatesAvailable: updatesAvailable);
    }
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

  Future<void> _getInstalledPackages() async {
    await _getPackages(
      ids: _installedPackages,
      onChanged: (v) => setInstalledPackagesChanged(v),
      filters: {PackageKitFilter.installed},
    );
  }

  Future<void> _getInstalledApps() async {
    await _getPackages(
      ids: _installedApps,
      onChanged: (v) => setInstalledAppsChanged(v),
      filters: {
        PackageKitFilter.installed,
        PackageKitFilter.gui,
        PackageKitFilter.newest,
        PackageKitFilter.application,
        PackageKitFilter.notDevelopment,
        PackageKitFilter.notSource,
        PackageKitFilter.visible,
      },
    );
  }

  Future<void> _getPackages({
    Set<PackageKitFilter> filters = const {},
    required Map<String, PackageKitPackageId> ids,
    required void Function(bool) onChanged,
  }) async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        ids.putIfAbsent(
          event.packageId.name,
          () => event.packageId,
        );
        onChanged(true);
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getPackages(
      filter: filters,
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
    final removeCompleter = Completer();
    setPackageState(PackageState.processing);
    removeTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        setInfo(event.info);
      } else if (event is PackageKitItemProgressEvent) {
        if (event.status == PackageKitStatus.remove) {
          setPackagePercentage(100 - event.percentage);
        }
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        removeCompleter.complete();
      }
    });
    await removeTransaction.removePackages([packageId]);
    await removeCompleter.future;
    if (_localId != null) {
      setIsInstalled(false);
    } else {
      isIdInstalled(id: packageId);
    }
    setPackageState(PackageState.ready);
  }

  /// Installs with package with [packageId]
  Future<void> install({required PackageKitPackageId packageId}) async {
    final installTransaction = await _client.createTransaction();
    setPackageState(PackageState.processing);
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        setInfo(event.info);
      } else if (event is PackageKitItemProgressEvent) {
        setPackagePercentage(event.percentage);
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
      }
    });
    await installTransaction.installPackages([packageId]);
    await installCompleter.future;
    isIdInstalled(id: packageId);
    setPackageState(PackageState.ready);
  }

  /// Check if an app with given [packageId] is installed.
  Future<void> isIdInstalled({required PackageKitPackageId id}) async {
    setPackageState(PackageState.processing);
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        final installed = event.info == PackageKitInfo.installed;
        setIsInstalled(installed);
        setPackagePercentage(installed ? 100 : 0);
      } else if (event is PackageKitErrorCodeEvent) {
        setErrorMessage('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });

    await transaction
        .searchNames([id.name], filter: {PackageKitFilter.installed});
    await completer.future;
    setPackageState(PackageState.ready);
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

  String? _searchQuery;
  PackageKitTransaction? _searchTransaction;

  Future<List<PackageKitPackageId>> findPackageKitPackageIds({
    required String searchQuery,
    Set<PackageKitFilter> filter = const {},
  }) async {
    _searchQuery = searchQuery;
    if (searchQuery.isEmpty) return [];
    await _searchTransaction?.cancel();
    // ensure max one search transaction at a time
    return synchronized(() async {
      if (searchQuery != _searchQuery) return [];
      final List<PackageKitPackageId> ids = [];
      final transaction = await _client.createTransaction();
      final completer = Completer();
      transaction.events.listen((event) {
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
        [searchQuery],
        filter: filter,
      );
      await completer.future;
      _searchTransaction = null;

      return ids.take(20).toList();
    });
  }

  PackageKitPackageId? _localId;

  /// Finds the [packageId] from [path] and sets info fields
  Future<void> getDetailsAboutLocalPackage({required String path}) async {
    if (path.isEmpty || !(await File(path).exists())) return;
    final transaction = await _client.createTransaction();
    final detailsCompleter = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        _localId = event.packageId;
        setProcessedId(event.packageId);
        setSummary(event.summary);
        setUrl(event.url);
        setLicense(event.license);
        setSize(event.size);
        setGroup(event.group);
        setDescription(event.description);
      } else if (event is PackageKitFinishedEvent) {
        detailsCompleter.complete();
      }
    });
    await transaction.getDetailsLocal([path]);
    await detailsCompleter.future;
    if (_localId != null) {
      await isIdInstalled(id: _localId!);
    }
  }

  Future<void> installLocalFile({required String? path}) async {
    if (path != null && path.isEmpty || !(await File(path!).exists())) return;
    final installTransaction = await _client.createTransaction();
    final installCompleter = Completer();
    setPackageState(PackageState.processing);
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
      } else if (event is PackageKitItemProgressEvent) {
        setPackagePercentage(event.percentage);
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
      }
    });
    await installTransaction.installFiles([path]);
    await installCompleter.future;
    if (_localId != null) {
      await isIdInstalled(id: _localId!);
    }
    setPackageState(PackageState.ready);
  }

  void reboot() {
    Process.start(
      'reboot',
      [],
      mode: ProcessStartMode.detached,
    );
  }

  // gnome-session-quit
  logout() {
    Process.start(
      'gnome-session-quit',
      [],
      mode: ProcessStartMode.detached,
    );
  }

  exitApp() => exit(0);
}
