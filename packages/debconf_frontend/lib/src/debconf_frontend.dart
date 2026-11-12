import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:debconf_frontend/src/debconf_question.dart';

/// A page of questions from one debconf GO command.
class DebconfPrompt {
  const DebconfPrompt({
    required this.title,
    required this.questions,
    this.canGoBack = false,
  });

  /// e.g. `Configuring tzdata`.
  final String title;

  final List<DebconfQuestion> questions;

  /// Whether the setup script supports going back to earlier questions.
  final bool canGoBack;
}

/// Answers a page of questions, e.g. by showing a dialog.
typedef DebconfPromptHandler = Future<DebconfDialogResult> Function(
  DebconfPrompt prompt,
);

/// The UI side of debconf's passthrough frontend, listening on a Unix socket.
///
/// Debconf connects to it when run with `DEBIAN_FRONTEND=passthrough` and
/// `DEBCONF_PIPE` set to [path], e.g. through PackageKit's `frontend-socket`
/// hint.
class DebconfFrontend {
  DebconfFrontend._(this.path, this._server, this._onPrompt) {
    _server.listen(
      (socket) => unawaited(_DebconfSession(socket, _onPrompt).run()),
    );
  }

  /// Listens on a Unix socket at [path], replacing a stale one.
  static Future<DebconfFrontend> bind(
    String path, {
    required DebconfPromptHandler onPrompt,
  }) async {
    await _deleteSocket(path);
    final server = await ServerSocket.bind(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
    return DebconfFrontend._(path, server, onPrompt);
  }

  final String path;
  final ServerSocket _server;
  final DebconfPromptHandler _onPrompt;

  /// Stops accepting connections and removes the socket.
  Future<void> close() async {
    await _server.close();
    await _deleteSocket(path);
  }
}

Future<void> _deleteSocket(String path) async {
  final type = await FileSystemEntity.type(path, followLinks: false);
  if (type != FileSystemEntityType.notFound) await File(path).delete();
}

/// Answers one debconf process, as documented in debconf's
/// Debconf/FrontEnd/Passthrough.pm.
class _DebconfSession {
  _DebconfSession(this._socket, this._onPrompt);

  final Socket _socket;
  final DebconfPromptHandler _onPrompt;
  final _fields = <String, Map<String, String>>{};
  final _values = <String, String>{};
  final _input = <String>[];
  var _title = '';
  var _canGoBack = false;

  Future<void> run() async {
    try {
      final lines = utf8.decoder.bind(_socket).transform(const LineSplitter());
      await for (final line in lines) {
        final reply = await _handle(line);
        // Closing the connection makes debconf fail the setup script.
        if (reply == null) break;
        _socket.write('$reply\n');
        await _socket.flush();
      }
    } on IOException {
      // Debconf went away, e.g. because the setup script was killed.
    } finally {
      _socket.destroy();
    }
  }

  Future<String?> _handle(String line) async {
    final (command, args) = _split(line);
    if (command == 'GO') return _go();
    switch (command) {
      case 'CAPB':
        // A plain CAPB asks what we support; `CAPB backup` comes from scripts.
        if (args.split(' ').contains('backup')) _canGoBack = true;
        return '0 backup';
      case 'TITLE':
        _title = args;
      case 'SETTITLE':
        _title = _fields[args]?['description'] ?? args;
      case 'DATA':
        final (tag, rest) = _split(args);
        final (field, value) = _split(rest);
        (_fields[tag] ??= {})[field] = value.replaceAll(r'\n', '\n');
      case 'SET':
        final (tag, value) = _split(args);
        _values[tag] = value;
      case 'INPUT':
        _input.add(_split(args).$2);
        return '0 question will be asked';
      case 'GET':
        return '0 ${_values[args] ?? ''}';
      case 'X_PING':
        return '0 pong';
      case 'SUBST' || 'PROGRESS' || 'INFO' || 'STOP':
        break;
      default:
        return '20 Unsupported command';
    }
    return '0 ok';
  }

  Future<String?> _go() async {
    final questions = [for (final tag in _input) ?_question(tag)];
    _input.clear();
    if (questions.isEmpty) return '0 ok';

    final result = await _onPrompt(
      DebconfPrompt(title: _title, questions: questions, canGoBack: _canGoBack),
    );
    switch (result) {
      case DebconfAnswered(:final values):
        _values.addAll(values);
        return '0 ok';
      case DebconfWentBack():
        return '30 backup';
      case DebconfCancelled():
        return null;
    }
  }

  DebconfQuestion? _question(String tag) {
    final fields = _fields[tag] ?? const {};
    final type = DebconfQuestionType.values.asNameMap()[fields['type']];
    if (type == null) return null;
    return DebconfQuestion(
      name: tag,
      type: type,
      description: fields['description'] ?? '',
      extendedDescription: fields['extended_description'] ?? '',
      choices: _splitChoices(fields['choices'] ?? ''),
      value: _values[tag] ?? '',
    );
  }
}

(String, String) _split(String text) {
  final space = text.indexOf(' ');
  return space < 0
      ? (text, '')
      : (text.substring(0, space), text.substring(space + 1));
}

// Like debconf's choices_split: `, ` separates choices, `\,` and `\ ` escape.
List<String> _splitChoices(String choices) {
  final items = <String>[];
  final item = StringBuffer();
  var start = 0;
  for (final match in RegExp(r'\\([, ])|,\s+').allMatches(choices)) {
    item.write(choices.substring(start, match.start));
    if (match[1] case final escaped?) {
      item.write(escaped);
    } else {
      items.add(item.toString());
      item.clear();
    }
    start = match.end;
  }
  item.write(choices.substring(start));
  if (item.isNotEmpty) items.add(item.toString());
  return items;
}
