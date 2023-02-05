import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/snap_service.dart';

class CollectionModel extends SafeChangeNotifier {
  CollectionModel(
    this._snapService,
    // this._packageService,
  );

  final SnapService _snapService;
  StreamSubscription<bool>? _snapChangesSub;

  // final PackageService _packageService;

  final Map<Snap, bool> _installedSnaps = {};
  Map<Snap, bool> get installedSnaps {
    final entryList = _installedSnaps.entries.toList();
    entryList.sort((a, b) {
      if (a.value) {
        return -1;
      } else {
        return 1;
      }
    });
    return Map.fromEntries(entryList);
  }

  bool get snapUpdatesAvailable =>
      _installedSnaps.entries.where((e) => e.value == true).toList().isNotEmpty;

  bool? _serviceIsBusy;
  bool? get serviceBusy => _serviceIsBusy;
  set serviceBusy(bool? value) {
    if (value == null || value == _serviceIsBusy) return;
    _serviceIsBusy = value;
    notifyListeners();
  }

  List<Snap> get _snapsWithUpdates => _installedSnaps.entries
      .where((e) => e.value == true)
      .map((e) => e.key)
      .toList();

  // final Map<PackageKitPackageId, bool>? _installedPackages = {};

  Future<void> init() async {
    await _loadInstalledSnaps();
    if (_snapService.snapChanges.isEmpty) {
      await checkForSnapUpdates();
    } else {
      checkingForSnapUpdates = false;
    }
    _snapChangesSub = _snapService.snapChangesInserted.listen((_) async {
      if (_snapService.snapChanges.isEmpty) {
        _installedSnaps.clear();
        _loadInstalledSnaps();
        serviceBusy = false;
      } else {
        serviceBusy = true;
      }
    });
  }

  Future<void> _loadInstalledSnaps() async {
    await _snapService.loadLocalSnaps();
    for (var snap in _snapService.localSnaps) {
      _installedSnaps.putIfAbsent(snap, () => false);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _snapChangesSub?.cancel();
    super.dispose();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  bool? _checkingForSnapUpdates;
  bool? get checkingForSnapUpdates => _checkingForSnapUpdates;
  set checkingForSnapUpdates(bool? value) {
    if (value == null || value == _checkingForSnapUpdates) return;
    _checkingForSnapUpdates = value;
    notifyListeners();
  }

  Future<void> checkForSnapUpdates() async {
    checkingForSnapUpdates = true;
    final snapsWithUpdate = await _snapService.loadSnapsWithUpdate();
    checkingForSnapUpdates = false;
    for (var update in snapsWithUpdate) {
      for (var e in _installedSnaps.entries) {
        if (e.key.name == update.name) {
          _installedSnaps.update(e.key, (value) => true);
          notifyListeners();
        }
      }
    }
  }

  Future<void> refreshAllSnapsWithUpdates({
    required String doneMessage,
  }) async {
    await _snapService.authorize();
    if (_snapsWithUpdates.isEmpty) return;

    final firstSnap = _snapsWithUpdates.first;
    _snapService
        .refresh(
      snap: firstSnap,
      message: doneMessage,
      channel: firstSnap.channel,
      confinement: firstSnap.confinement,
    )
        .then((_) {
      notifyListeners();
      for (var snap in _snapsWithUpdates.skip(1)) {
        _snapService.refresh(
          snap: snap,
          message: doneMessage,
          confinement: snap.confinement,
          channel: snap.channel,
        );
        notifyListeners();
      }
    });
  }

  // Future<void> _checkForPackageUpdates() async {}
}
