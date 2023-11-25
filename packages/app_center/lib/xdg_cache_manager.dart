// Temporary workaround to use the proper XDG cache directory with cached_network_image.
// See https://github.com/flutter/flutter/issues/105386 and
// https://github.com/Baseflow/flutter_cache_manager/issues/416

import 'dart:io';

import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// see https://github.com/Baseflow/flutter_cache_manager/issues/365
// ignore: implementation_imports
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:path/path.dart' as p;
import 'package:xdg_directories/xdg_directories.dart' as xdg;

class _XdgFileSystem implements FileSystem {
  final Future<Directory> _fileDir;
  final String _cacheKey;

  _XdgFileSystem(this._cacheKey) : _fileDir = createDirectory(_cacheKey);

  static Future<Directory> createDirectory(String key) async {
    final baseDir = xdg.cacheHome;
    final path = p.join(baseDir.path, key, 'images');

    const fs = LocalFileSystem();
    final directory = fs.directory(path);
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    final directory = await _fileDir;
    if (!(await directory.exists())) {
      await createDirectory(_cacheKey);
    }
    return directory.childFile(name);
  }
}

class XdgCacheManager extends CacheManager with ImageCacheManager {
  static final key = p.basename(Platform.resolvedExecutable);

  static final XdgCacheManager _instance = XdgCacheManager._();

  factory XdgCacheManager() {
    return _instance;
  }

  XdgCacheManager._() : super(Config(key, fileSystem: _XdgFileSystem(key)));
}
