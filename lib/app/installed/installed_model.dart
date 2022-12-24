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
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/snap/snap_sort.dart';

class InstalledModel extends SafeChangeNotifier {
  final PackageService _packageService;
  InstalledModel(
    this._packageService,
    this._snapService,
  );

  StreamSubscription<bool>? _installedSub;

  List<PackageKitPackageId> get installedPackages =>
      _packageService.isAvailable ? _packageService.installedPackages : [];

  final SnapService _snapService;
  StreamSubscription<bool>? _snapChangesSub;

  // Local snaps
  List<Snap> get localSnaps => _snapService.localSnaps;
  bool _isLoadingSnapsCompleted = false;
  bool get isLoadingSnapsCompleted => _isLoadingSnapsCompleted;
  Future<void> loadLocalSnaps() async {
    _snapService.loadLocalSnaps().whenComplete(() {
      _isLoadingSnapsCompleted = true;
      notifyListeners();
    });
  }

  // Local snaps with update
  Future<List<Snap>> get localSnapsWithUpdate async =>
      await _snapService.loadSnapsWithUpdate();

  Future<void> init() async {
    _snapChangesSub = _snapService.snapChangesInserted.listen((_) {
      if (_snapService.snapChanges.isEmpty) {}
    });
    _enabledAppFormats.add(AppFormat.snap);
    if (_packageService.isAvailable) {
      _enabledAppFormats.add(AppFormat.packageKit);
      _installedSub = _packageService.installedPackagesChanged.listen((event) {
        notifyListeners();
      });
      await _packageService.getInstalledPackages(filters: packageKitFilters);
    }

    await loadLocalSnaps();
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    _installedSub?.cancel();

    super.dispose();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  final Set<AppFormat> _enabledAppFormats = {};
  Set<AppFormat> get enabledAppFormats => _enabledAppFormats;
  AppFormat _appFormat = AppFormat.snap;
  AppFormat get appFormat => _appFormat;
  void setAppFormat(AppFormat value) {
    if (value == _appFormat) return;
    _appFormat = value;
    _loadSnapsWithUpdates = false;
    if (_appFormat == AppFormat.packageKit && _packageService.isAvailable) {
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
    if (!_packageService.isAvailable) return;
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
    notifyListeners();
  }

  bool _loadSnapsWithUpdates = false;
  bool get loadSnapsWithUpdates => _loadSnapsWithUpdates;
  set loadSnapsWithUpdates(bool value) {
    if (value == _loadSnapsWithUpdates) return;
    _loadSnapsWithUpdates = value;
    notifyListeners();
  }
}
