import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:app_center/appstream/logger.dart';
import 'package:appstream/appstream.dart';

/// The system directories that may contain AppStream catalog metadata, in
/// the same order as used by [AppstreamPool].
const _defaultCatalogDirPrefixes = ['/usr/share', '/var/lib', '/var/cache'];

class _LoadArgs {
  const _LoadArgs(this.port, this.path);
  final SendPort port;
  final String path;
}

/// An [AppstreamPool] that tolerates malformed catalog files.
///
/// [AppstreamPool.load] spawns one isolate per catalog file and waits for
/// all of them via `Future.wait`. If a single file fails to parse (for
/// example because it uses a release `type` that the `appstream` package
/// doesn't recognize, such as `snapshot`), the isolate throws an unhandled
/// exception and dies without ever responding on its `ReceivePort`. Since
/// nothing ever arrives on that port, `Future.wait` never completes, which
/// means the whole application silently loses all AppStream metadata:
/// search, categories, and snap/deb detail pages hang forever waiting on
/// [AppstreamPool.load] (see #2142).
///
/// This subclass re-implements the same directory scanning/parsing logic,
/// but catches parsing errors on a per-file basis, so a single malformed
/// catalog file is skipped (and logged) instead of blocking every other
/// file from loading.
class ResilientAppstreamPool extends AppstreamPool {
  ResilientAppstreamPool({
    this.catalogDirPrefixes = _defaultCatalogDirPrefixes,
  });

  final List<String> catalogDirPrefixes;

  @override
  Future<void> load() async {
    final catalogDirs = <String>[];
    for (final prefix in catalogDirPrefixes) {
      final catalogPath = '$prefix/swcatalog';
      final catalogLegacyPath = '$prefix/app-info';

      // Only use the legacy path if it's not a symlink to the current path.
      final legacyLink = Link(catalogLegacyPath);
      final ignoreLegacyPath =
          await legacyLink.exists() && await legacyLink.target() == catalogPath;

      catalogDirs.add(catalogPath);
      if (!ignoreLegacyPath) {
        catalogDirs.add(catalogLegacyPath);
      }
    }

    final collectionFutures = <Future<AppstreamCollection?>>[];
    for (final dir in catalogDirs) {
      for (final path in await _listFiles(dir)) {
        collectionFutures.add(_loadCollection(_loadXmlInIsolate, path));
      }
      for (final path in await _listFiles('$dir/yaml')) {
        collectionFutures.add(_loadCollection(_loadYamlInIsolate, path));
      }
    }

    final collections = await Future.wait(collectionFutures);
    for (final collection in collections) {
      if (collection != null) {
        components.addAll(collection.components);
      }
    }
  }

  static Future<List<String>> _listFiles(String path) async {
    final dir = Directory(path);
    try {
      return await dir
          .list()
          .where((e) => e is File)
          .map((e) => e.path)
          .toList();
    } on FileSystemException {
      return [];
    }
  }

  static Future<AppstreamCollection?> _loadCollection(
    void Function(_LoadArgs args) entryPoint,
    String path,
  ) async {
    final port = ReceivePort();
    final isolate = await Isolate.spawn<_LoadArgs>(
      entryPoint,
      _LoadArgs(port.sendPort, path),
    );
    final result = await port.first;
    isolate.kill(priority: Isolate.immediate);
    port.close();
    if (result is AppstreamCollection) {
      return result;
    }
    log.warning('Failed to load AppStream catalog "$path": $result');
    return null;
  }

  static void _loadXmlInIsolate(_LoadArgs args) =>
      _parseInIsolate(args, AppstreamCollection.fromXml);

  static void _loadYamlInIsolate(_LoadArgs args) =>
      _parseInIsolate(args, AppstreamCollection.fromYaml);

  static Future<void> _parseInIsolate(
    _LoadArgs args,
    AppstreamCollection Function(String contents) parse,
  ) async {
    try {
      final contents = await _loadFile(args.path);
      args.port.send(parse(contents));
    } on Object catch (error) {
      // Sent back as a plain string: exceptions thrown by the `appstream`
      // package aren't guaranteed to be safe to send across the isolate
      // boundary, and we only need the message for logging anyway.
      args.port.send('$error');
    }
  }

  static Future<String> _loadFile(String path) async {
    var stream = File(path).openRead();
    if (path.endsWith('.gz')) {
      stream = gzip.decoder.bind(stream);
    }
    return utf8.decoder.bind(stream).join();
  }
}
