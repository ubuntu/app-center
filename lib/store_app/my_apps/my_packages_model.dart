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
import 'package:software/services/package_service.dart';

class MyPackagesModel extends SafeChangeNotifier {
  final PackageService _service;
  MyPackagesModel(this._service);

  StreamSubscription<bool>? _installedSub;

  List<PackageKitPackageId> get installedApps => _service.installedApps;

  void init() async {
    _installedSub = _service.installedAppsChanged.listen((event) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _installedSub?.cancel();
    super.dispose();
  }
}
