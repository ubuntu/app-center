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

import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:launcher_entry/launcher_entry.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/appstream/appstream_utils.dart';
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

    _enabledAppFormats.add(AppFormat.snap);
    _selectedAppFormats.add(AppFormat.snap);

    await _packageService.initialized;
    if (_packageService.isAvailable) {
      _appstreamService.init().then((_) {
        _enabledAppFormats.add(AppFormat.packageKit);
        _selectedAppFormats.add(AppFormat.packageKit);
        notifyListeners();
      });
    }
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

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery({String? value, bool notify = false}) {
    _errorMessage = '';
    _searchQuery = value;
    if (notify == true) {
      notifyListeners();
    }
  }

  bool? _searchActive;
  bool? get searchActive => _searchActive;
  void setSearchActive(bool? value) {
    if (value == null || value == _searchActive) return;
    _searchActive = value;
    notifyListeners();
  }

  SnapSection? _selectedSection = SnapSection.all;
  SnapSection? get selectedSection => _selectedSection;
  void setSelectedSection(SnapSection? value) {
    if (value == null || value == _selectedSection) return;
    _selectedSection = value;
    notifyListeners();
  }

  Map<SnapSection, List<Snap>> get sectionNameToSnapsMap =>
      _snapService.sectionNameToSnapsMap;

  final Set<AppFormat> _selectedAppFormats = {};
  Set<AppFormat> get selectedAppFormats => Set.from(_selectedAppFormats);
  final Set<AppFormat> _enabledAppFormats = {};
  Set<AppFormat> get enabledAppFormats => Set.from(_enabledAppFormats);
  void handleAppFormat(AppFormat appFormat) {
    if (!_selectedAppFormats.contains(appFormat)) {
      _selectedAppFormats.add(appFormat);
    } else {
      if (_selectedAppFormats.length < 2) return;
      _selectedAppFormats.remove(appFormat);
    }
    notifyListeners();
  }

  Future<List<Snap>> _findSnapsByQuery(String searchQuery) async {
    try {
      return await _snapService.findSnapsByQuery(
        searchQuery: searchQuery,
        sectionName:
            selectedSection == null || selectedSection == SnapSection.all
                ? null
                : selectedSection!.title,
      );
    } on SnapdException catch (e) {
      errorMessage = e.message.toString();
      return [];
    }
  }

  Future<List<AppstreamComponent>> _findAppstreamComponents(
    String searchQuery,
  ) async =>
      _appstreamService.search(searchQuery);

  Map<String, AppFinding>? _searchResult;
  Map<String, AppFinding>? get searchResult => _searchResult;
  set searchResult(Map<String, AppFinding>? value) {
    _searchResult = value;
    notifyListeners();
  }

  Future<void> search() async {
    searchResult = null;

    final Map<String, AppFinding> appFindings = {};
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      if (selectedAppFormats
          .containsAll([AppFormat.snap, AppFormat.packageKit])) {
        final snaps = await _findSnapsByQuery(searchQuery!);
        for (final snap in snaps) {
          appFindings.putIfAbsent(
            snap.name,
            () => AppFinding(snap: snap),
          );
        }

        final components = await _findAppstreamComponents(searchQuery!);
        for (final component in components) {
          final snap =
              snaps.firstWhereOrNull((snap) => snap.name == component.package);
          if (snap == null) {
            appFindings.putIfAbsent(
              component.localizedName(),
              () => AppFinding(appstream: component),
            );
          } else {
            appFindings.update(
              snap.name,
              (value) => AppFinding(
                snap: snap,
                appstream: component,
              ),
            );
          }
        }
      } else if (selectedAppFormats.contains(AppFormat.snap) &&
          !(selectedAppFormats.contains(AppFormat.packageKit))) {
        final snaps = await _findSnapsByQuery(searchQuery!);
        for (final snap in snaps) {
          appFindings.putIfAbsent(
            snap.name,
            () => AppFinding(snap: snap),
          );
        }
      } else if (!selectedAppFormats.contains(AppFormat.snap) &&
          (selectedAppFormats.contains(AppFormat.packageKit))) {
        final components = await _findAppstreamComponents(searchQuery!);
        for (final component in components) {
          appFindings.putIfAbsent(
            component.localizedName(),
            () => AppFinding(appstream: component),
          );
        }
      }

      searchResult = appFindings;
    }
  }

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
