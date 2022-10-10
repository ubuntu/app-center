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
import 'package:software/services/package_service.dart';
import 'package:software/updates_state.dart';
import 'package:window_manager/window_manager.dart';

const repoUrl = 'https://github.com/ubuntu-flutter-community/software';

class SettingsModel extends SafeChangeNotifier {
  final PackageService _packageService;

  String appName;

  String packageName;

  String version;

  String buildNumber;
  SettingsModel(this._packageService)
      : appName = '',
        packageName = '',
        version = '',
        buildNumber = '';

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    notifyListeners();
  }

  void quit() {
    windowManager.setPreventClose(false);
    windowManager.close();
  }

  bool get isUpdateRunning =>
      _packageService.lastUpdatesState == UpdatesState.updating ||
      _packageService.lastUpdatesState == UpdatesState.checkingForUpdates;
}
