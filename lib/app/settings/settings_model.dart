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

import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/services/packagekit/package_service.dart';

const _repoUrl = 'https://github.com/ubuntu-flutter-community/software';

class SettingsModel extends SafeChangeNotifier {
  final PackageService _packageService;
  SettingsModel(this._packageService);

  String? _appName;
  String? get appName => _appName;
  set appName(String? value) {
    if (value == null || value == _appName) return;
    _appName = value;
    notifyListeners();
  }

  String? _packageName;
  String? get packageName => _packageName;
  set packageName(String? value) {
    if (value == null || value == _packageName) return;
    _packageName = value;
    notifyListeners();
  }

  String? _version;
  String? get version => _version;
  set version(String? value) {
    if (value == null || value == _version) return;
    _version = value;
    notifyListeners();
  }

  String? _buildNumber;
  String? get buildNumber => _buildNumber;
  set buildNumber(String? value) {
    if (value == null || value == _buildNumber) return;
    _buildNumber = value;
    notifyListeners();
  }

  bool get packageKitAvailable => _packageService.isAvailable;

  String get repoUrl => _repoUrl;

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    notifyListeners();
  }
}
