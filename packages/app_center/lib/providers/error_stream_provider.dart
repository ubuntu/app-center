import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'error_stream_provider.g.dart';

/// Used to listen to incoming errors to show them to the user.
final errorStreamProvider = StreamProvider<Exception>(
  (ref) => ref.watch(errorStreamControllerProvider).stream,
);

@Riverpod(keepAlive: true)
ErrorStreamController errorStreamController(Ref ref) {
  return getService<ErrorStreamController>();
}

typedef ErrorStreamController = StreamController<Exception>;
