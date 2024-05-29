import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fileSystemProvider = Provider<FileSystem>((_) => const LocalFileSystem());
