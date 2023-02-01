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
import 'package:window_manager/window_manager.dart';

class AppModel extends SafeChangeNotifier implements WindowListener {
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

  UpdatesState? _updatesState;
  UpdatesState? get updatesState => _updatesState;
  set updatesState(UpdatesState? value) {
    _updatesState = value;
    notifyListeners();
  }

  final _sidebarEventController = StreamController<bool>.broadcast();
  Stream<bool> get sidebarEvents => _sidebarEventController.stream;
  int _selectedIndex = 0;
  set selectedIndex(int index) {
    if (_selectedIndex == index) {
      _sidebarEventController.add(true);
    } else {
      _selectedIndex = index;
    }
  }

  int get updateAmount => _packageService.updates.length;

  bool get updatesProcessing =>
      updatesState == UpdatesState.checkingForUpdates ||
      updatesState == UpdatesState.updating;

  void Function()? _onAskForQuit;

  Future<void> init({required void Function() onAskForQuit}) async {
    _onAskForQuit = onAskForQuit;
    windowManager.setPreventClose(true);
    windowManager.addListener(this);

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
        _launcherEntryService.update(count: updateAmount, countVisible: true);
      } else {
        _launcherEntryService.update(count: 0, countVisible: false);
      }
    });

    _updatesPercentageSub =
        _packageService.updatesPercentage.listen((percentage) {
      if (percentage == null) {
        _launcherEntryService.update(progressVisible: false);
      } else {
        _launcherEntryService.update(
          progress: percentage / 100.0,
          progressVisible: true,
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

  void quit() {
    windowManager.setPreventClose(false);
    windowManager.close();
  }

  bool get readyToQuit =>
      updatesState == null ||
      updatesState == UpdatesState.readyToUpdate ||
      updatesState == UpdatesState.noUpdates;

  @override
  void onWindowBlur() {}

  @override
  void onWindowClose() {
    if (readyToQuit) {
      quit();
    } else {
      if (_onAskForQuit != null) {
        _onAskForQuit!();
      }
    }
  }

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowEvent(String eventName) {}

  @override
  void onWindowFocus() {}

  @override
  void onWindowLeaveFullScreen() {}

  @override
  void onWindowMaximize() {}

  @override
  void onWindowMinimize() {}

  @override
  void onWindowMove() {}

  @override
  void onWindowMoved() {}

  @override
  void onWindowResize() {}

  @override
  void onWindowResized() {}

  @override
  void onWindowRestore() {}

  @override
  void onWindowUnmaximize() {}
}
