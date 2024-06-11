import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Used to provide a [StreamController] to propagate errors.
final errorControllerProvider = Provider<StreamController<Exception>>(
  (_) => StreamController<Exception>(),
);

/// Used to listen to incoming errors to show them to the user.
final errorProvider = StreamProvider<Exception>(
  (ref) => ref.watch(errorControllerProvider).stream,
);
