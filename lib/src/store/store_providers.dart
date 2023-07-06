import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtk/gtk.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/routes.dart';

final commandLineProvider = StateProvider((ref) {
  final app = getService<GtkApplicationNotifier>();
  void handleCommandLine(List<String> args) => ref.controller.state = args;
  app.addCommandLineListener(handleCommandLine);
  ref.onDispose(() => app.removeCommandLineListener(handleCommandLine));
  return app.commandLine;
});

final initialRouteProvider = Provider((ref) {
  final snap = ref.watch(commandLineProvider)?.singleOrNull;
  if (snap != null) {
    return Uri(path: Routes.detail, queryParameters: {'snap': snap}).toString();
  }
  return null;
});
