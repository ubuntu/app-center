import 'dart:async';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:snapd/snapd.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

@visibleForTesting
final cachePath =
    '${xdg.cacheHome.path}/${p.basename(Platform.resolvedExecutable)}/snapd';

class CacheFile {
  CacheFile(
    String path, {
    Duration? expiry,
    FileSystem? fs,
    MessageCodec<Object?> codec = const StandardMessageCodec(),
  })  : _file = (fs ?? const LocalFileSystem()).file(path),
        _expiry = expiry ?? Duration.zero,
        _codec = codec;

  CacheFile.fromFileName(
    String fileName, {
    Duration? expiry,
    FileSystem? fs,
  }) : this(
          '$cachePath/$fileName.smc',
          expiry: expiry,
          fs: fs,
        );

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
