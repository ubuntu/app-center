import 'dart:async';
import 'dart:io';

import 'package:app_center/packagekit/logger.dart';
import 'package:debconf_frontend/debconf_frontend.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// A page of debconf questions waiting for the user.
class DebconfRequest {
  DebconfRequest(this.prompt);

  final DebconfPrompt prompt;
  final _result = Completer<DebconfDialogResult>();

  /// Completes once the user has answered.
  Future<DebconfDialogResult> get result => _result.future;

  void answer(DebconfDialogResult result) => _result.complete(result);
}

/// Lets package setup scripts ask their debconf questions in App Center.
class DebconfService {
  DebconfService({@visibleForTesting String? runtimeDir})
    : _runtimeDir = runtimeDir ?? Platform.environment['XDG_RUNTIME_DIR'];

  final String? _runtimeDir;
  Future<DebconfFrontend?>? _frontend;

  /// Questions to show; they get their default answers while nobody listens.
  Stream<DebconfRequest> get requests => _requests.stream;
  final _requests = StreamController<DebconfRequest>.broadcast();

  /// The socket to pass to PackageKit, or null if questions can't be asked.
  Future<String?> socketPath() async => (await (_frontend ??= _start()))?.path;

  // The runtime dir is private to the user, and packagekitd can see it.
  Future<DebconfFrontend?> _start() async {
    final dir = _runtimeDir;
    if (dir == null) return null;
    try {
      return await DebconfFrontend.bind(
        p.join(dir, 'app-center-debconf-$pid.socket'),
        onPrompt: _ask,
      );
    } on IOException catch (e) {
      log.warning('Could not listen for debconf questions: $e');
      return null;
    }
  }

  Future<DebconfDialogResult> _ask(DebconfPrompt prompt) {
    if (!_requests.hasListener) {
      return Future.value(
        DebconfAnswered({
          for (final question in prompt.questions)
            question.name: question.value,
        }),
      );
    }
    final request = DebconfRequest(prompt);
    _requests.add(request);
    return request.result;
  }

  Future<void> dispose() async {
    await (await _frontend)?.close();
    await _requests.close();
  }
}
