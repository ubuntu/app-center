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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/updates_state.dart';

class StoreModel extends SafeChangeNotifier {
  StoreModel(
    this._connectivity,
    this._snapService,
    this._packageService,
  );

  final SnapService _snapService;
  Map<Snap, SnapdChange> get snapChanges => _snapService.snapChanges;
  StreamSubscription<bool>? _snapChangesSub;

  final Connectivity _connectivity;
  StreamSubscription? _connectivitySub;
  ConnectivityResult? _connectivityResult = ConnectivityResult.wifi;
  ConnectivityResult? get state => _connectivityResult;

  final PackageService _packageService;
  StreamSubscription<bool>? _updatesChangedSub;
  StreamSubscription<UpdatesState>? _updatesStateSub;

  UpdatesState? _updatesState;
  UpdatesState? get updatesState => _updatesState;
  set updatesState(UpdatesState? value) {
    _updatesState = value;
    notifyListeners();
  }

  int get updateAmount => _packageService.updates.length;

  Future<void> init() async {
    await _packageService.init();

    _snapChangesSub = _snapService.snapChangesInserted.listen((_) {
      notifyListeners();
    });
    initConnectivity();
    _updatesChangedSub = _packageService.updatesChanged.listen((event) {
      notifyListeners();
    });
    _updatesStateSub = _packageService.updatesState.listen((event) {
      updatesState = event;
      if (_updatesAvailable != null) {
        _packageService.sendUpdateNotification(
          updatesAvailable: _updatesAvailable!,
        );
      }
    });
  }

  String? _updatesAvailable;
  void setupNotifications({required String updatesAvailable}) {
    _updatesAvailable = updatesAvailable;
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    _connectivitySub?.cancel();
    _updatesChangedSub?.cancel();
    _updatesStateSub?.cancel();

    super.dispose();
  }

  Future<void> refreshConnectivity() {
    return _connectivity.checkConnectivity().then((state) {
      _connectivityResult = state;
      notifyListeners();
    });
  }

  bool get appIsOnline =>
      _connectivityResult == ConnectivityResult.ethernet ||
      _connectivityResult == ConnectivityResult.wifi;

  Future<void> initConnectivity() async {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((result) {
      _connectivityResult = result;

      notifyListeners();
    });
    return refreshConnectivity();
  }
}
