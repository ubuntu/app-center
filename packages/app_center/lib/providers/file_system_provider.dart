import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the correct file system to use for the environment.
/// The file system is a [MemoryFileSystem] when running widget tests and a
/// [LocalFileSystem] otherwise.
final fileSystemProvider = Provider<FileSystem>(
  (_) => Platform.environment.containsKey('FLUTTER_TEST')
      ? MemoryFileSystem()
      : const LocalFileSystem(),
);
