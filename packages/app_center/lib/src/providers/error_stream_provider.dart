import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

/// Used to listen to incoming errors to show them to the user.
final errorStreamProvider = StreamProvider<Exception>(
  (ref) => getService<ErrorStreamController>().stream,
);

typedef ErrorStreamController = StreamController<Exception>;
