import 'package:args/args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtk/gtk.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/routes.dart';

final commandLineProvider = Provider.autoDispose((ref) {
  final app = getService<GtkApplicationNotifier>();
  void handleCommandLine(List<String> args) => ref.invalidateSelf();
  app.addCommandLineListener(handleCommandLine);
  ref.onDispose(() => app.removeCommandLineListener(handleCommandLine));
  return app.commandLine;
});

final initialRouteProvider = Provider.autoDispose((ref) {
  return _parseRoute(ref.watch(commandLineProvider));
});

final routeStreamProvider = StreamProvider.autoDispose((ref) async* {
  final args = _parseRoute(ref.watch(commandLineProvider));
  if (args != null) yield args;
});

String? _parseRoute(List<String>? args) {
  final parser = ArgParser();
  parser.addOption('snap', valueHelp: 'name', help: 'Show snap details');
  parser.addOption('search', valueHelp: 'query', help: 'Search for snaps');

  try {
    final result = parser.parse(args ?? []);

    final query = result['search'] as String?;
    if (query != null) {
      return Routes.withArgument(Routes.search, 'query', query);
    }

    final snap = result['snap'] as String? ?? result.rest.singleOrNull;
    if (snap != null) {
      return Routes.withArgument(Routes.detail, 'snap', snap);
    }
  } on FormatException {
    // TODO: print usage
  }

  return null;
}
