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

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/snap_service.dart';

class SnapUpdatesModel extends SafeChangeNotifier {
  SnapUpdatesModel(
    this._snapService,
  );

  final SnapService _snapService;
  StreamSubscription<bool>? _snapChangesSub;
  StreamSubscription<String>? _refreshErrorSub;
  List<Snap>? _snapsWithUpdates;
  List<Snap>? get snapsWithUpdates => _snapsWithUpdates;

  Future<void> init({Function(String)? onRefreshError}) async {
    _snapChangesSub = _snapService.snapChangesInserted.listen((_) {
      checkingForUpdates = true;
      if (_snapService.snapChanges.isEmpty) {
        _loadSnapsWithUpdate().then((_) => checkingForUpdates = false);
      }
    });
    _refreshErrorSub = _snapService.refreshError.listen((event) {
      if (onRefreshError != null) {
        onRefreshError(event);
      }
    });

    await checkForUpdates();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    await _refreshErrorSub?.cancel();
    super.dispose();
  }

  bool _checkingForUpdates = false;
  bool get checkingForUpdates => _checkingForUpdates;
  set checkingForUpdates(bool value) {
    if (value == _checkingForUpdates) return;
    _checkingForUpdates = value;
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    checkingForUpdates = true;
    _snapsWithUpdates = await _loadSnapsWithUpdate();
    checkingForUpdates = false;
  }

  Future<List<Snap>> _loadSnapsWithUpdate() async =>
      await _snapService.loadSnapsWithUpdate();

  Future<void> refreshAll({
    required String doneMessage,
  }) async {
    await _snapService.authorize();
    if (_snapsWithUpdates == null) return;

    final firstSnap = _snapsWithUpdates!.first;
    _snapService
        .refresh(
      snap: firstSnap,
      message: doneMessage,
      channel: firstSnap.channel,
      confinement: firstSnap.confinement,
    )
        .then((_) {
      notifyListeners();
      for (var snap in _snapsWithUpdates!.skip(1)) {
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
}
