import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/services/package_service.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class UpdatesModel extends SafeChangeNotifier {
  final PackageService _service;
  StreamSubscription<String>? _errorMessageSub;
  StreamSubscription<bool>? _requireRestartSub;
  StreamSubscription<int?>? _percentageSub;
  StreamSubscription<PackageKitInfo?>? _infoSub;
  StreamSubscription<PackageKitStatus?>? _statusSub;
  StreamSubscription<PackageKitPackageId?>? _processedIdSub;
  StreamSubscription<UpdatesState>? _updatesStateSub;
  StreamSubscription<bool>? _installedSub;
  StreamSubscription<String>? _manualRepoNameSub;
  StreamSubscription<bool>? _reposChangedSub;
  StreamSubscription<bool>? _updatesChangedSub;

  UpdatesModel()
      : _service = getService<PackageService>(),
        _requireRestart = false,
        _errorMessage = '',
        _manualRepoName = '';

  void init() async {
    _updatesStateSub = _service.updatesState.listen((event) {
      updatesState = event;
    });
    _errorMessageSub = _service.errorMessage.listen((event) {
      errorMessage = event;
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
    super.dispose();
  }

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

  Future<void> refresh() async {
    await _service.refresh();
    notifyListeners();
  }

  Future<void> updateAll() async {
    await _service.updateAll();
  }

  List<PackageKitRepositoryDetailEvent> get repos => _service.repos;

  // Not implemented in packagekit.dart
  Future<void> addRepo() async {
    await _service.addRepo(manualRepoName);
  }

  Future<void> toggleRepo({required String id, required bool value}) async {
    await _service.toggleRepo(id: id, value: value);
  }

  void reboot() {
    _service.reboot();
  }
}
