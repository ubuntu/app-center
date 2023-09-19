import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:packagekit/packagekit.dart';
import 'package:path/path.dart' as p;
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;
import 'package:yaru_widgets/yaru_widgets.dart';

import 'appstream.dart';
import 'config.dart';
import 'l10n.dart';
import 'packagekit.dart';
import 'ratings.dart';
import 'snapd.dart';
import 'store.dart';

Future<void> main(List<String> args) async {
  await YaruWindowTitleBar.ensureInitialized();

  final snapd = SnapdService();
  await snapd.loadAuthorization();
  registerServiceInstance(snapd);

  final launcher = PrivilegedDesktopLauncher();
  await launcher.connect();
  registerServiceInstance(launcher);

  final config = ConfigService();
  config.load();

  final ratings =
      RatingsService(config.ratingServiceUrl, config.ratingsServicePort);
  registerServiceInstance(config);
  registerServiceInstance(ratings);

  registerService(() => GitHub());
  registerService(() => GtkApplicationNotifier(args));

  final appstream = AppstreamService();
  // Explicitly ignore the future to continue while appstream is reading the
  // metadata from the disk.
  unawaited(appstream.init());
  registerServiceInstance(appstream);

  registerService(() => PackageKitClient());
  registerService(() => PackageKitService(),
      dispose: (service) => service.dispose());

  await initDefaultLocale();

  final binaryName = p.basename(Platform.resolvedExecutable);
  Logger.setup(
    path: p.join(
      xdg.dataHome.path,
      binaryName,
      '$binaryName.log',
    ),
  );

  runApp(const ProviderScope(child: StoreApp()));
}
