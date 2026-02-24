import 'package:app_center/store/store_routes.dart';
import 'package:args/args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtk/gtk.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

const _kUrlPrefix = 'snap://';
const _kDebSuffix = '.deb';

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
  parser.addFlag('updates', negatable: false, help: 'Show manage page');
  parser.addMultiOption(
    'gst',
    splitCommas: false,
    valueHelp: 'gstreamer resource tuple',
    help: 'Install a set of gstreamer resources',
  );

  try {
    if (args?.firstOrNull?.startsWith(_kUrlPrefix) ?? false) {
      final uri = Uri.parse(args!.first);
      final snap = uri.path;
      if (snap.isNotEmpty) {
        final channel = uri.queryParameters['channel'];
        if (channel != null) {
          return StoreRoutes.namedSnap(name: snap, channel: channel);
        } else {
          return StoreRoutes.namedSnap(name: snap);
        }
      }
    }

    if (args?.firstOrNull?.endsWith(_kDebSuffix) ?? false) {
      final debPath = args!.first;
      return StoreRoutes.namedLocalDeb(path: debPath);
    }

    final result = parser.parse(args ?? []);

    final query = result['search'] as String?;
    if (query != null) {
      return StoreRoutes.namedSearch(query: query);
    }

    final snap = result['snap'] as String? ?? result.rest.singleOrNull;
    if (snap != null) {
      return StoreRoutes.namedSnap(name: snap);
    }

    if (result.flag('updates')) {
      return StoreRoutes.manage;
    }

    final gstResources = result.multiOption('gst');
    if (gstResources.isNotEmpty) {
      return StoreRoutes.namedGStreamer(resources: gstResources);
    }
  } on FormatException {
    // TODO: print usage
  }

  return null;
}
