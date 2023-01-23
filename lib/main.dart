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
import 'package:gtk_application/gtk_application.dart';
import 'package:launcher_entry/launcher_entry.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/app.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_session/ubuntu_session.dart';
import 'package:window_manager/window_manager.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await YaruWindowTitleBar.ensureInitialized();

  windowManager.setPreventClose(false);

  registerService<AppstreamService>(AppstreamService.new);
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
  );
  registerService<UbuntuSession>(UbuntuSession.new);

  registerService<SnapdClient>(SnapdClient.new, dispose: (s) => s.close());
  registerService<Connectivity>(Connectivity.new);
  registerService<SnapService>(SnapService.new);

  registerService<GtkApplicationNotifier>(
    () => GtkApplicationNotifier(args),
    dispose: (s) => s.dispose(),
  );

  registerService<LauncherEntryService>(
    (() => LauncherEntryService(
          appUri: 'application://snap-store_snap-store.desktop',
        )),
  );

  runApp(App.create());
}
