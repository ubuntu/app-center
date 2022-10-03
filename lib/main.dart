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

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:software/package_installer/package_installer_app.dart';
import 'package:software/services/color_generator.dart';
import 'package:software/services/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/store_app/store_app.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_session/ubuntu_session.dart';
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setPreventClose(true);
  windowManager.addListener(MyWindowListener());

  registerService<NotificationsClient>(
    NotificationsClient.new,
    dispose: (s) => s.close(),
  );
  registerService<PackageKitClient>(
    PackageKitClient.new,
    dispose: (service) => service.close(),
  );
  registerService<PackageService>(
    PackageService.new,
    dispose: (s) => s.dispose(),
  );
  registerService<SessionManager>(
    SessionManager.new,
    dispose: (s) => s.close(),
  );

  final loadPackageInstaller =
      args.isNotEmpty && args.any((arg) => arg.endsWith('.deb'));

  if (!loadPackageInstaller) {
    registerService<ColorGenerator>(DominantColorGenerator.new);
    registerService<SnapdClient>(SnapdClient.new, dispose: (s) => s.close());
    registerService<Connectivity>(Connectivity.new);
    registerService<SnapService>(SnapService.new);

    runApp(StoreApp.create());
  } else {
    final path = args.where((arg) => arg.endsWith('.deb')).first;
    runApp(
      PackageInstallerApp(path: path),
    );
  }
}

class MyWindowListener implements WindowListener {
  @override
  void onWindowBlur() {}

  @override
  void onWindowClose() {
    /// To check for updates even in the background, we hide the window on app close.
    /// The App is still closeable from the settings page.
    windowManager.hide();
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
