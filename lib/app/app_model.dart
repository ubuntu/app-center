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

import 'package:launcher_entry/launcher_entry.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/services/packagekit/updates_state.dart';

class AppModel extends SafeChangeNotifier {
  AppModel(
    this._snapService,
    this._appstreamService,
    this._packageService,
    this._launcherEntryService,
  );

  final SnapService _snapService;
  Map<Snap, SnapdChange> get snapChanges => _snapService.snapChanges;
  StreamSubscription<bool>? _snapChangesSub;

  final AppstreamService _appstreamService;

  final PackageService _packageService;
  StreamSubscription<bool>? _updatesChangedSub;
  StreamSubscription<UpdatesState>? _updatesStateSub;
  StreamSubscription<int?>? _updatesPercentageSub;

  final LauncherEntryService _launcherEntryService;
  var _launcherEntryProgress = 0.0;
  var _launcherEntryProgressVisible = false;

  void updateLauncherEntry() => _launcherEntryService.update(
        count: updateAmount,
        countVisible: updateAmount > 0,
        progress: _launcherEntryProgress,
        progressVisible: _launcherEntryProgressVisible,
      );

  UpdatesState? _updatesState;
  UpdatesState? get updatesState => _updatesState;
  set updatesState(UpdatesState? value) {
    _updatesState = value;
    notifyListeners();
  }

  final _sidebarEventController = StreamController<bool>.broadcast();
  Stream<bool> get sidebarEvents => _sidebarEventController.stream;
  int _selectedIndex = 0;
  void setSelectedIndex(int index) {
    if (_selectedIndex == index) {
      _sidebarEventController.add(true);
    } else {
      _selectedIndex = index;
    }
  }

  int get updateAmount =>
      _packageService.updates.length + _snapService.snapsWithUpdate.length;

  bool get updatesProcessing =>
      updatesState == UpdatesState.checkingForUpdates ||
      updatesState == UpdatesState.updating;

  Future<void> init() async {
    try {
      _snapService.init();
    } on SnapdException catch (e) {
      errorMessage = e.message;
    }
    _appstreamService.init();

    _snapChangesSub = _snapService.snapChangesInserted.listen((_) {
      notifyListeners();
    });
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
      updateLauncherEntry();
    });

    _updatesPercentageSub =
        _packageService.updatesPercentage.listen((percentage) {
      if (percentage == null) {
        _launcherEntryProgressVisible = false;
      } else {
        _launcherEntryProgressVisible = true;
        _launcherEntryProgress = percentage / 100.0;
      }
      updateLauncherEntry();
    });
  }

  String? _updatesAvailable;
  void setupNotifications({required String updatesAvailable}) {
    _updatesAvailable = updatesAvailable;
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    _updatesChangedSub?.cancel();
    _updatesStateSub?.cancel();
    _updatesPercentageSub?.cancel();

    super.dispose();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) {
    if (value == _errorMessage) return;
    _errorMessage = value;
    notifyListeners();
  }

  bool get readyToQuit =>
      updatesState == null ||
      updatesState == UpdatesState.readyToUpdate ||
      updatesState == UpdatesState.noUpdates;
}
