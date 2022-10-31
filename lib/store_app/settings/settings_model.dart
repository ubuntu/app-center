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

const repoUrl = 'https://github.com/ubuntu-flutter-community/software';

class SettingsModel extends SafeChangeNotifier {
  String appName;

  String packageName;

  String version;

  String buildNumber;
  SettingsModel()
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
}
