import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:snapd/snapd.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

mixin SnapdCache on SnapdClient {
  @visibleForTesting
  static final cachePath =
      '${xdg.cacheHome.path}/${p.basename(Platform.resolvedExecutable)}/snapd';

  @visibleForTesting
  static CacheFile cacheFile(
    String fileName, {
    Duration? expiry,
    FileSystem? fs,
  }) {
    return CacheFile('$cachePath/$fileName.smc', expiry: expiry, fs: fs);
  }

  Stream<List<Snap>> getCategory(
    String name, {
    Duration expiry = const Duration(days: 1),
    @visibleForTesting FileSystem? fs,
  }) async* {
    final file = cacheFile('category-$name', expiry: expiry, fs: fs);
    if (file.existsSync()) {
      final snaps = await file.readSnapList();
      if (snaps != null) yield snaps;
    }
    if (!file.isValidSync()) {
      final snaps = await find(category: name);
      yield snaps;
      await Isolate.run(() async {
        file.writeSnapListSync(snaps);
        for (final snap in snaps) {
          final snapFile = cacheFile('snap-${snap.name}');
          if (!snapFile.existsSync()) {
            snapFile.writeSnapSync(snap);
          }
        }
      });
    }
  }

  Stream<Snap?> getStoreSnap(
    String name, {
    Duration expiry = const Duration(minutes: 1),
    @visibleForTesting FileSystem? fs,
  }) async* {
    final file = cacheFile('snap-$name', expiry: expiry, fs: fs);
    var hasChannels = false;
    if (file.existsSync()) {
      final snap = await file.readSnap();
      if (snap != null) {
        yield snap;
        hasChannels = snap.channels.isNotEmpty;
      }
    }
    if (!hasChannels || !file.isValidSync()) {
      try {
        final snap = await find(name: name).then((r) => r.single);
        yield snap;
        await file.writeSnap(snap);
      } on SnapdException catch (e) {
        if (e.kind == 'snap-not-found') {
          yield null;
        } else {
          rethrow;
        }
      }
    }
  }

  /// Fetches the snaps given by [names] from the store. First yields a list of
  /// cached snaps, where available, and continues to fetch them from the store in
  /// case the cached files are missing/expired or the channel information is
  /// missing.
  Stream<List<Snap>> getStoreSnaps(
    List<String> names, {
    Duration expiry = const Duration(minutes: 1),
    @visibleForTesting FileSystem? fs,
  }) async* {
    // Read and yield cached snaps
    final cacheFiles = {
      for (final name in names)
        name: cacheFile('snap-$name', expiry: expiry, fs: fs)
    };
    final cachedSnaps = Map.fromEntries(
      await Future.wait(
        cacheFiles.entries.map(
          (e) async => MapEntry(
            e.key,
            e.value.existsSync() ? await e.value.readSnap() : null,
          ),
        ),
      ),
    );
    yield cachedSnaps.values.whereNotNull().toList();

    // Fetch and yield snaps from the store if necessary
    final writeToCache = <String, Snap>{};
    final storeSnaps = await Future.wait(
      cachedSnaps.entries.map(
        (e) async {
          if ((e.value?.channels.isEmpty ?? true) ||
              !cacheFiles[e.key]!.isValidSync()) {
            try {
              final snap = await find(name: e.key).then((r) => r.single);
              writeToCache[e.key] = snap;
              return snap;
            } on SnapdException catch (e) {
              if (e.kind == 'snap-not-found') {
                return null;
              } else {
                rethrow;
              }
            }
          } else {
            return e.value;
          }
        },
      ),
    );
    yield storeSnaps.whereNotNull().toList();

    // Save fetched snaps in the cache
    for (final e in writeToCache.entries) {
      await cacheFiles[e.key]!.write(e.value);
    }
  }
}

@visibleForTesting
extension SnapCacheFile on CacheFile {
  Future<Snap?> readSnap() async {
    final data = await read() as Map?;
    return data != null ? Snap.fromJson(data.cast()) : null;
  }

  Future<List<Snap>?> readSnapList() async {
    final data = await read() as List?;
    return data
        ?.cast<Map<Object?, Object?>>()
        .map((s) => Snap.fromJson(s.cast()))
        .toList();
  }

  Future<void> writeSnap(Snap snap) => write(snap.toJson());

  void writeSnapSync(Snap snap) => writeSync(snap.toJson());

  void writeSnapListSync(List<Snap> snaps) {
    return writeSync(snaps.map((snap) => snap.toJson()).toList());
  }
}

@visibleForTesting
class CacheFile {
  CacheFile(
    String path, {
    Duration? expiry,
    FileSystem? fs,
    MessageCodec<Object?> codec = const StandardMessageCodec(),
  })  : _file = (fs ?? const LocalFileSystem()).file(path),
        _expiry = expiry ?? Duration.zero,
        _codec = codec;

  final File _file;
  final Duration _expiry;
  final MessageCodec<Object?> _codec;

  String get path => _file.path;

  bool existsSync() => _file.existsSync();

  bool isValidSync([DateTime? now]) {
    try {
      return _file
          .lastModifiedSync()
          .add(_expiry)
          .isAfter(now ?? DateTime.now());
    } on FileSystemException {
      return false;
    }
  }

  Future<Object?> read() async {
    try {
      final bytes = await _file.readAsBytes();
      return bytes.decodeCache(_codec);
    } on FormatException {
      return null;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> write(Object object) async {
    if (!await _file.parent.exists()) {
      await _file.parent.create(recursive: true);
    }
    final bytes = object.encodeCache(_codec);
    await _file.writeAsBytes(bytes);
  }

  void writeSync(Object object) {
    if (!_file.parent.existsSync()) {
      _file.parent.createSync(recursive: true);
    }
    final bytes = object.encodeCache(_codec);
    _file.writeAsBytesSync(bytes);
  }
}

extension CacheObject on Object {
  Uint8List encodeCache(MessageCodec<Object?> codec) {
    final data = codec.encodeMessage(_toMessage())!;
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  dynamic _toMessage() {
    try {
      return (this as dynamic).toJson();
    } on NoSuchMethodError {
      return this;
    }
  }
}

extension CacheUint8List on Uint8List {
  Object? decodeCache(MessageCodec<Object?> codec) {
    return codec.decodeMessage(ByteData.sublistView(this));
  }
}
