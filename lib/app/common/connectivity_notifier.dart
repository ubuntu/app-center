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

class ConnectivityNotifier extends SafeChangeNotifier {
  ConnectivityNotifier(this._connectivity);

  final Connectivity _connectivity;
  StreamSubscription? _subscription;
  ConnectivityResult? _result;

  bool get isOnline => _result != ConnectivityResult.none;

  Future<void> init() async {
    _subscription ??=
        _connectivity.onConnectivityChanged.listen(_updateConnectivity);
    return _connectivity.checkConnectivity().then(_updateConnectivity);
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    super.dispose();
  }

  void _updateConnectivity(ConnectivityResult result) {
    if (_result == result) return;
    _result = result;
    notifyListeners();
  }
}
