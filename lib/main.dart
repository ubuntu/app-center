import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'appstream.dart';
import 'l10n.dart';
import 'snapd.dart';
import 'src/ratings/ratings_service.dart';
import 'store.dart';

Future<void> main(List<String> args) async {
  await YaruWindowTitleBar.ensureInitialized();

  final snapd = SnapdService();
  await snapd.loadAuthorization();
  registerServiceInstance(snapd);

  final launcher = PrivilegedDesktopLauncher();
  await launcher.connect();
  registerServiceInstance(launcher);

  // TODO: Dev/prod url's, determine on .env var
  final ratings = RatingsService("localhost", 8080);
  registerServiceInstance(ratings);

  registerService(() => GitHub());
  registerService(() => GtkApplicationNotifier(args));

  final appstream = AppstreamService();
  // Explicitly ignore the future to continue while appstream is reading the
  // metadata from the disk.
  unawaited(appstream.init());
  registerServiceInstance(appstream);

  await initDefaultLocale();

  Logger.setup();

  runApp(const ProviderScope(child: StoreApp()));
}
