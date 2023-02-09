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

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:ubuntu_session/ubuntu_session.dart';

class PackageUpdatesModel extends SafeChangeNotifier {
  final PackageService _service;
  final UbuntuSession _session;
  StreamSubscription<String>? _errorMessageSub;
  StreamSubscription<PackageKitRestart>? _requireRestartSub;
  StreamSubscription<int?>? _percentageSub;
  StreamSubscription<PackageKitInfo?>? _infoSub;
  StreamSubscription<PackageKitStatus?>? _statusSub;
  StreamSubscription<PackageKitPackageId?>? _processedIdSub;
  StreamSubscription<UpdatesState>? _updatesStateSub;
  StreamSubscription<bool>? _installedSub;
  StreamSubscription<String>? _manualRepoNameSub;
  StreamSubscription<bool>? _reposChangedSub;
  StreamSubscription<bool>? _updatesChangedSub;
  StreamSubscription<bool>? _selectionChanged;

  PackageUpdatesModel(
    this._service,
    this._session,
  )   : _requireRestart = PackageKitRestart.none,
        _errorMessage = '',
        _manualRepoName = '';

  Future<void> init({
    required void Function() handleError,
    bool? loadRepoList,
  }) async {
    // Init the model with the last values
    _updatesState = _service.lastUpdatesState;
    _processedId = _service.lastProcessedId;
    _info = _service.lastInfo;
    _percentage = _service.lastUpdatesPercentage;
    _requireRestart = _service.lastRequireRestart ?? PackageKitRestart.none;

    // Setup all stream subscriptions
    _updatesStateSub = _service.updatesState.listen((event) {
      updatesState = event;
    });
    _errorMessageSub = _service.errorMessage.listen((event) {
      errorMessage = event;
      handleError();
    });
    _requireRestartSub = _service.requireRestart.listen((event) {
      requireRestart = event;
    });
    _percentageSub = _service.updatesPercentage.listen((event) {
      percentage = event;
    });
    _infoSub = _service.info.listen((event) {
      info = event;
    });
    _statusSub = _service.status.listen((event) {
      status = event;
    });
    _processedIdSub = _service.processedId.listen((event) {
      processedId = event;
    });
    _manualRepoNameSub = _service.manualRepoName.listen((event) {
      manualRepoName = event;
    });
    _updatesChangedSub = _service.updatesChanged.listen((event) {
      notifyListeners();
    });
    _installedSub = _service.installedPackagesChanged.listen((event) {
      notifyListeners();
    });
    _reposChangedSub = _service.reposChanged.listen((event) {
      notifyListeners();
    });
    _selectionChanged = _service.selectionChanged.listen((event) {
      notifyListeners();
    });

    _service.getInstalledPackages(forUpdates: true);
    if (loadRepoList == true) {
      _service.loadRepoList();
    }
  }

  @override
  void dispose() {
    _errorMessageSub?.cancel();
    _requireRestartSub?.cancel();
    _percentageSub?.cancel();
    _infoSub?.cancel();
    _statusSub?.cancel();
    _processedIdSub?.cancel();
    _updatesStateSub?.cancel();
    _manualRepoNameSub?.cancel();
    _updatesChangedSub?.cancel();
    _installedSub?.cancel();
    _reposChangedSub?.cancel();
    _selectionChanged?.cancel();
    super.dispose();
  }

  Stream<String> get terminalOutput => _service.terminalOutput;
  List<PackageKitPackageId> get updates => _service.updates;
  PackageKitPackageId getUpdate(int index) => _service.getUpdate(index);
  PackageKitGroup getGroup(PackageKitPackageId id) =>
      _service.getGroup(id) ?? PackageKitGroup.unknown;
  bool isUpdateSelected(PackageKitPackageId id) =>
      _service.isUpdateSelected(id);
  PackageKitPackageId? getInstalledId(String name) =>
      _service.getInstalledId(name);
  void selectUpdate(PackageKitPackageId id, bool value) =>
      _service.selectUpdate(id, value);

  String _errorMessage;
  String get errorMessage => _errorMessage;
  set errorMessage(String value) {
    if (value == _errorMessage) return;
    _errorMessage = value;
    notifyListeners();
  }

  PackageKitRestart _requireRestart;
  bool get requireRestartApp =>
      _requireRestart == PackageKitRestart.application;
  bool get requireRestartSession =>
      _requireRestart == PackageKitRestart.session;
  bool get requireRestartSystem => _requireRestart == PackageKitRestart.system;
  set requireRestart(PackageKitRestart value) {
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

  PackageKitPackageId? _processedId;
  PackageKitPackageId? get processedId => _processedId;
  set processedId(PackageKitPackageId? value) {
    if (value == _processedId) return;
    _processedId = value;
    notifyListeners();
  }

  UpdatesState? _updatesState;
  UpdatesState? get updatesState => _updatesState;
  set updatesState(UpdatesState? value) {
    if (value == _updatesState) return;
    _updatesState = value;
    notifyListeners();
  }

  String _manualRepoName;
  String get manualRepoName => _manualRepoName;
  set manualRepoName(String value) {
    if (value == _manualRepoName) return;
    _manualRepoName = value;
    notifyListeners();
  }

  void selectAll() {
    _service.selectAll();
  }

  void deselectAll() {
    _service.deselectAll();
  }

  bool get allSelected => _service.allSelected;
  bool get nothingSelected => _service.nothingSelected;
  int get selectedUpdatesLength => _service.selectedUpdatesLength;

  Future<void> refresh() async {
    await _service.refreshUpdates();
    notifyListeners();
  }

  Future<void> updateAll({
    required String updatesComplete,
    required String updatesAvailable,
  }) async {
    await _service.updateAll(
      updatesComplete: updatesComplete,
      updatesAvailable: updatesAvailable,
    );
  }

  List<PackageKitRepositoryDetailEvent> get repos => _service.repos;

  // Not implemented in packagekit.dart
  Future<void> addRepo() async {
    await _service.addRepo(manualRepoName);
  }

  Future<void> toggleRepo({required String id, required bool value}) async {
    await _service.toggleRepo(id: id, value: value);
  }

  void reboot() => _session.reboot();

  void logout() => _session.logout();

  void exitApp() => _service.exitApp();
}
