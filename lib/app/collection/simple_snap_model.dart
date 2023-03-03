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
import 'dart:io';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/snap_service.dart';

class SimpleSnapModel extends SafeChangeNotifier {
  SimpleSnapModel(
    this._snapService, {
    required this.snap,
  });

  Future<void> init() async {
    await _snapService.authorize();
    await _loadChange();

    _snapChangesSub = _snapService.snapChangesInserted.listen((_) async {
      await _loadChange();

      notifyListeners();
    });

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }

  /// The service to handle all snap related actions.
  final SnapService _snapService;

  /// Mainly used for the information about the install [SnapChannel] and
  /// the [SnapConnection]s. It is used as a fallback for some information
  /// if the snap is offline.
  final Snap snap;

  /// [StreamSubscription] to listen to snap changes.
  StreamSubscription<bool>? _snapChangesSub;

  /// Checks if the app is started as a snap.
  bool get isSnapEnv => Platform.environment['SNAP']?.isNotEmpty == true;

  /// The first change in progress for [huskSnapName]
  SnapdChange? _change;
  SnapdChange? get change => _change;
  set change(SnapdChange? value) {
    if (value == _change) return;
    _change = value;
    notifyListeners();
  }

  /// Loads the first change in progress for [huskSnapName] from [SnapService]
  Future<void> _loadChange() async {
    change = (await _snapService.getSnapChanges(name: snap.name));
  }

  Future<void> abortChange() async {
    await _snapService.abortChange(snap);
    return _loadChange();
  }

  Future<void> remove(String doneMessage) async {
    await _snapService.remove(snap, doneMessage);
    notifyListeners();
  }

  Future<void> refresh(String doneMessage) async {
    await _snapService.refresh(
      snap: snap,
      message: doneMessage,
      channel: snap.channel,
      confinement: snap.confinement,
    );
    notifyListeners();
  }

  void open() {
    if (snap.apps.isEmpty) return;
    Process.start(
      snap.apps.first.name,
      [],
      mode: ProcessStartMode.detached,
    );
  }
}
