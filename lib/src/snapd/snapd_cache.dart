import 'dart:async';
import 'dart:isolate';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:glib/glib.dart';
import 'package:meta/meta.dart';
import 'package:snapd/snapd.dart';

mixin SnapdCache on SnapdClient {
  @visibleForTesting
  static final cachePath =
      '${glib.getUserCacheDir()}/${glib.getProgramName()}/snapd';

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

  Stream<Snap> getStoreSnap(
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
      // TODO: null if the snap doesn't exist
      final snap = await find(name: name).then((r) => r.single);
      yield snap;
      await file.writeSnap(snap);
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
    return data?.cast<Map>().map((s) => Snap.fromJson(s.cast())).toList();
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
    MessageCodec codec = const StandardMessageCodec(),
  })  : _file = (fs ?? const LocalFileSystem()).file(path),
        _expiry = expiry ?? Duration.zero,
        _codec = codec;

  final File _file;
  final Duration _expiry;
  final MessageCodec _codec;

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
  Uint8List encodeCache(MessageCodec codec) {
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
  Object? decodeCache(MessageCodec codec) {
    return codec.decodeMessage(ByteData.sublistView(this));
  }
}
