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
import 'package:snapd/snapd.dart';
import 'package:software/services/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/store_app/common/app_format.dart';
import 'package:software/store_app/common/snap/snap_sort.dart';
import 'package:software/store_app/common/snap/snap_utils.dart';

class InstalledModel extends SafeChangeNotifier {
  final PackageService _packageService;
  InstalledModel(
    this._packageService,
    this._snapService,
  ) : _localSnaps = [];

  StreamSubscription<bool>? _installedSub;

  List<PackageKitPackageId> get installedPackages =>
      _packageService.installedPackages;

  final SnapService _snapService;
  StreamSubscription<bool>? _snapChangesSub;
  final List<Snap> _localSnaps;
  List<Snap> get localSnaps => _localSnaps;

  Future<void> init() async {
    await _loadLocalSnaps();
    _localSnaps.sort((a, b) => a.name.compareTo(b.name));
    _snapChangesSub = _snapService.snapChangesInserted.listen((_) {
      if (_snapService.snapChanges.isEmpty) {
        _loadLocalSnaps().then((value) => notifyListeners());
      }
    });
    _installedSub = _packageService.installedPackagesChanged.listen((event) {
      notifyListeners();
    });
    await _packageService.getInstalledPackages(filters: packageKitFilters);

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    _installedSub?.cancel();

    super.dispose();
  }

  Future<void> _loadLocalSnaps() async {
    List<Snap> snaps =
        await _snapService.getLocalSnaps().timeout(const Duration(seconds: 40));

    if (snaps.isNotEmpty) {
      _localSnaps.clear();
      _localSnaps.addAll(snaps);
    }
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  set searchQuery(String? value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  AppFormat _appFormat = AppFormat.snap;
  AppFormat get appFormat => _appFormat;
  void setAppFormat(AppFormat value) {
    if (value == _appFormat) return;
    _appFormat = value;
    _loadSnapsWithUpdates = false;
    if (_appFormat == AppFormat.packageKit) {
      _packageService.getInstalledPackages().then((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  final Set<PackageKitFilter> _packageKitFilters = {
    PackageKitFilter.installed,
    PackageKitFilter.gui,
    PackageKitFilter.newest,
    PackageKitFilter.application,
    PackageKitFilter.notSource,
  };
  Set<PackageKitFilter> get packageKitFilters => _packageKitFilters;
  Future<void> handleFilter(bool value, PackageKitFilter filter) async {
    if (value) {
      _packageKitFilters.add(filter);
    } else {
      _packageKitFilters.remove(filter);
    }
    await _packageService.getInstalledPackages(filters: packageKitFilters);
    notifyListeners();
  }

  bool _busy = false;
  bool get busy => _busy;
  set busy(bool value) {
    if (value == _busy) return;
    _busy = value;
    notifyListeners();
  }

  SnapSort _snapSort = SnapSort.name;
  SnapSort get snapSort => _snapSort;
  void setSnapSort(SnapSort value) {
    if (value == _snapSort) return;
    _snapSort = value;
    switch (snapSort) {
      case SnapSort.name:
        _localSnaps.sort((a, b) => a.name.compareTo(b.name));
        break;

      case SnapSort.size:
        _localSnaps.sort(
          (a, b) {
            if (a.installedSize == null || b.installedSize == null) return 0;
            return b.installedSize!.compareTo(a.installedSize!);
          },
        );
        break;

      case SnapSort.installDate:
        _localSnaps.sort(
          (a, b) {
            if (a.installDate == null || b.installDate == null) return 0;
            return a.installDate!.compareTo(b.installDate!);
          },
        );
        break;
    }
    notifyListeners();
  }

  bool _loadSnapsWithUpdates = false;
  bool get loadSnapsWithUpdates => _loadSnapsWithUpdates;
  set loadSnapsWithUpdates(bool value) {
    if (value == _loadSnapsWithUpdates) return;
    _loadSnapsWithUpdates = value;
    busy = true;
    if (value) {
      _loadSnapsWithUpdate().then((_) => busy = false);
    } else {
      _loadLocalSnaps().then((_) => busy = false);
    }
  }

  Future<void> _loadSnapsWithUpdate() async {
    await _loadLocalSnaps();
    Map<Snap, Snap> localSnapsToStoreSnaps = {};
    for (var snap in _localSnaps) {
      final storeSnap = await _snapService.findSnapByName(snap.name) ?? snap;
      localSnapsToStoreSnaps.putIfAbsent(snap, () => storeSnap);
    }

    final snapsWithUpdates = _localSnaps.where((snap) {
      if (localSnapsToStoreSnaps[snap] == null) return false;
      return isSnapUpdateAvailable(
        storeSnap: localSnapsToStoreSnaps[snap]!,
        localSnap: snap,
      );
    }).toList();

    _localSnaps.clear();
    _localSnaps.addAll(snapsWithUpdates);
  }

  Future<void> updateAll({required String doneMessage}) async {
    await _snapService.authorize().then((_) async {
      for (var snap in _localSnaps) {
        await _snapService.refresh(
          snap: snap,
          message: doneMessage,
          confinement: snap.confinement,
          channel: snap.channel,
        );
        notifyListeners();
      }
    }).then((_) => loadSnapsWithUpdates = false);
  }
}
