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

class MyAppsModel extends SafeChangeNotifier {
  final PackageService _packageService;
  MyAppsModel(
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
    final snaps = (await _snapService.getLocalSnaps())
        .where(
          (snap) => _snapService.getChange(snap) == null,
        )
        .toList();
    snaps.sort((a, b) => a.name.compareTo(b.name));
    _localSnaps.clear();
    _localSnaps.addAll(snaps);
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
    notifyListeners();
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
}
