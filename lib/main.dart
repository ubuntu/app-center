import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'l10n.dart';
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

  registerService(() => GitHub());
  registerService(() => GtkApplicationNotifier(args));

  await initDefaultLocale();

  runApp(const ProviderScope(child: StoreApp()));
}
