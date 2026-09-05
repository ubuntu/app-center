import 'package:app_center/store/store_routes.dart';
import 'package:args/args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtk/gtk.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

const _kSnapUrlPrefix = 'snap://';
const _kAppCenterUrlPrefix = 'appcenter://';
const _kDebSuffix = '.deb';

final commandLineProvider = Provider.autoDispose((ref) {
  final app = getService<GtkApplicationNotifier>();
  void handleCommandLine(List<String> args) => ref.invalidateSelf();
  app.addCommandLineListener(handleCommandLine);
  ref.onDispose(() => app.removeCommandLineListener(handleCommandLine));
  return app.commandLine;
});

final unifiedDetailsEnabledProvider = Provider.autoDispose(
  (ref) =>
      ref.watch(commandLineProvider)?.contains('--unified-details') ?? false,
);

final initialRouteProvider = Provider.autoDispose((ref) {
  return _parseRoute(ref.watch(commandLineProvider));
});

final routeStreamProvider = StreamProvider.autoDispose((ref) async* {
  final route = _parseRoute(ref.watch(commandLineProvider));
  // The initial request is handled by initialRouteProvider. Only forward new
  // requests here so the initial page isn't pushed twice.
  if (!ref.isFirstBuild && route != null) yield route;
});

String? _parseRoute(List<String>? args) {
  final parser = ArgParser();
  parser.addOption('snap', valueHelp: 'name', help: 'Show snap details');
  parser.addOption('search', valueHelp: 'query', help: 'Search for snaps');
  parser.addFlag('updates', negatable: false, help: 'Show manage page');
  parser.addFlag(
    'unified-details',
    negatable: false,
    help: 'Use unified details pages for snaps and Debian packages',
  );
  parser.addMultiOption(
    'gst',
    splitCommas: false,
    valueHelp: 'gstreamer resource tuple',
    help: 'Install a set of gstreamer resources',
  );

  try {
    final argument = args?.firstOrNull;
    if (argument?.toLowerCase().startsWith(_kAppCenterUrlPrefix) ?? false) {
      return _parseAppCenterRoute(Uri.parse(argument!));
    }

    if (args?.firstOrNull?.startsWith(_kSnapUrlPrefix) ?? false) {
      final uri = Uri.parse(args!.first);
      final snap = uri.host.isNotEmpty
          ? uri.host
          : uri.path.replaceAll('/', '');
      final channel = uri.queryParameters['channel'];
      if (snap.isNotEmpty) {
        return StoreRoutes.namedSnap(name: snap, channel: channel);
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

String? _parseAppCenterRoute(Uri uri) {
  // Only handle appcenter://addons/* routes for now.
  // Add switches for other routes in the future if needed.
  if (uri.host != 'addons') return null;

  final path = uri.path.endsWith('/')
      ? uri.path.substring(0, uri.path.length - 1)
      : uri.path;

  return switch (path) {
    '/media-support' => StoreRoutes.mediaSupport,
    _ => StoreRoutes.addons,
  };
}
