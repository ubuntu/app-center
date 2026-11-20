#!/usr/bin/env dart
// SDK-neutral customer-testing driver for App Center.
//
// This script invokes the `flutter` and `dart` executables that are on PATH.
// It never selects, installs or downloads an SDK, and it never edits tracked
// source files. The Flutter Customer Test Registry owns its own update phase
// between `prepare` and `test`.

import 'dart:convert';
import 'dart:io';

const _appPackage = 'packages/app_center';
const _ratingsPackage = 'packages/app_center_ratings_client';
const _ratingsOverridePath = '../app_center_ratings_client';
final _packageName = RegExp(r'^[a-z][a-z0-9_]*$');
final _documentMarker = RegExp(r'^(---|\.\.\.)( |$)');

// These cases deliberately avoid pumpApp()/pumpScopedApp(), FontLoader,
// XDG, D-Bus, GTK, network and real-file I/O so they can run against an
// unmodified Flutter SDK checkout.
const _selectedCases = <({String file, String name})>[
  // package_format_dialog_test.dart
  (
    file: 'package_format_dialog_test.dart',
    name: 'lists every format without a warning when none installed',
  ),
  (
    file: 'package_format_dialog_test.dart',
    name: 'explains the publisher badge',
  ),
  (
    file: 'package_format_dialog_test.dart',
    name: 'blocks installing another format while one is installed',
  ),
  (
    file: 'package_format_dialog_test.dart',
    name: 'does not warn when the only format is installed',
  ),
  (
    file: 'package_format_dialog_test.dart',
    name: 'warns when several formats are installed',
  ),
  (
    file: 'package_format_dialog_test.dart',
    name: 'installs the snap from the picked channel',
  ),
  (
    file: 'package_format_dialog_test.dart',
    name: 'switches the channel of an installed snap',
  ),
  // uninstall_dependents_dialog_test.dart
  (
    file: 'uninstall_dependents_dialog_test.dart',
    name: 'lists every dependent and confirms',
  ),
  (file: 'uninstall_dependents_dialog_test.dart', name: 'cancel declines'),
  (
    file: 'uninstall_dependents_dialog_test.dart',
    name: 'shows a scrollbar only when the list overflows',
  ),
  (
    file: 'uninstall_dependents_dialog_test.dart',
    name: 'package names are selectable',
  ),
  (
    file: 'uninstall_dependents_dialog_test.dart',
    name: 'scrolls a long list',
  ),
  // markdown_description_test.dart
  (
    file: 'markdown_description_test.dart',
    name: 'markdown follows the dark theme and selection color',
  ),
  // material_localizations_test.dart
  (
    file: 'material_localizations_test.dart',
    name: 'markdown selection menu uses en Material labels',
  ),
  (
    file: 'material_localizations_test.dart',
    name: 'markdown selection menu uses fr Material labels',
  ),
  (
    file: 'material_localizations_test.dart',
    name: 'markdown selection menu uses dz Material labels',
  ),
];

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 ||
      (arguments.single != 'prepare' && arguments.single != 'test')) {
    _usage(arguments);
    exitCode = 64;
    return;
  }

  final root = Directory.current;
  final command = arguments.single;
  print('[driver] command=$command root=${root.path}');
  final succeeded =
      command == 'prepare' ? await _prepare(root) : await _test(root);
  print('[driver] command=$command exit=${succeeded ? 0 : 1}');
  if (!succeeded) {
    exitCode = 1;
  }
}

void _usage(List<String> arguments) {
  stderr.writeln(
    'Usage: dart run scripts/customer_testing.dart <prepare|test>',
  );
  if (arguments.isNotEmpty) {
    stderr.writeln('Unknown command: ${arguments.join(' ')}');
  }
}

Future<bool> _prepare(Directory root) async {
  if (!_mergeRatingsOverride(root)) {
    return false;
  }
  await _recordEnvironment(root, 'prepare');

  final ratings = _packageDirectory(root, _ratingsPackage);
  final app = _packageDirectory(root, _appPackage);

  if (!await _runPhase('ratings-get', 'flutter', ['pub', 'get'], ratings)) {
    return false;
  }
  if (!await _runPhase('app-get', 'flutter', ['pub', 'get'], app)) {
    return false;
  }
  if (!await _regenerate(ratings, app)) {
    return false;
  }
  return true;
}

Future<bool> _test(Directory root) async {
  final ratings = _packageDirectory(root, _ratingsPackage);
  final app = _packageDirectory(root, _appPackage);

  await _recordEnvironment(root, 'test');

  if (!await _regenerate(ratings, app)) {
    return false;
  }

  final failures = <String>[];
  for (var index = 0; index < _selectedCases.length; index++) {
    final selected = _selectedCases[index];
    final label = 'case-${(index + 1).toString().padLeft(2, '0')}';
    final passed = await _runSelectedCase(label, selected, app);
    if (!passed) {
      failures.add('${selected.file}: ${selected.name}');
    }
  }

  print(
    '[driver] summary command=test total=${_selectedCases.length} '
    'passed=${_selectedCases.length - failures.length} '
    'failed=${failures.length}',
  );
  for (final failure in failures) {
    stderr.writeln('[driver] failed case=$failure');
  }
  return failures.isEmpty;
}

Future<bool> _regenerate(Directory ratings, Directory app) async {
  if (!await _runPhase(
      'ratings-generate',
      'dart',
      [
        'run',
        'build_runner',
        'build',
      ],
      ratings)) {
    return false;
  }
  if (!await _runPhase(
      'app-generate',
      'dart',
      [
        'run',
        'build_runner',
        'build',
      ],
      app)) {
    return false;
  }
  return _runPhase('app-gen-l10n', 'flutter', ['gen-l10n'], app);
}

Directory _packageDirectory(Directory root, String package) {
  return Directory('${root.path}/$package');
}

Future<bool> _runPhase(
  String label,
  String executable,
  List<String> arguments,
  Directory workingDirectory,
) async {
  final argv = <String>[executable, ...arguments];
  print(
    '[driver] phase=$label start cwd=${workingDirectory.path} '
    'argv=${jsonEncode(argv)}',
  );
  final stopwatch = Stopwatch()..start();
  var exit = 1;
  try {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory.path,
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    exit = await process.exitCode;
  } on ProcessException catch (error) {
    exit = 127;
    stderr.writeln('[driver] phase=$label process-error=${error.message}');
  } finally {
    stopwatch.stop();
  }
  print(
    '[driver] phase=$label cwd=${workingDirectory.path} '
    'argv=${jsonEncode(argv)} exit=$exit seconds=${_seconds(stopwatch)}',
  );
  return exit == 0;
}

Future<bool> _runSelectedCase(
  String label,
  ({String file, String name}) selected,
  Directory appDirectory,
) async {
  final arguments = <String>[
    'test',
    '--no-pub',
    '--machine',
    '--name',
    '^${RegExp.escape(selected.name)}\$',
    'test/${selected.file}',
  ];
  final argv = <String>['flutter', ...arguments];
  print(
    '[driver] phase=$label start cwd=${appDirectory.path} '
    'argv=${jsonEncode(argv)}',
  );
  final stopwatch = Stopwatch()..start();
  final captured = await _runCaptured('flutter', arguments, appDirectory);
  stopwatch.stop();

  final machine = _interpretMachineOutput(captured.stdout, selected.name);
  final passed = captured.exit == 0 && machine.passed;
  final reason = passed ? 'passed' : _caseFailureReason(captured.exit, machine);

  _writeEvidence('cases/$label.stdout.log', captured.stdout);
  _writeEvidence('cases/$label.stderr.log', captured.stderr);
  if (!passed && _evidenceRoot() == null) {
    stderr.writeln('[driver] case=$label raw-machine-stdout-begin');
    stderr.write(captured.stdout);
    stderr.writeln('[driver] case=$label raw-machine-stdout-end');
    stderr.write(captured.stderr);
  }

  print(
    '[driver] case=$label name=${jsonEncode(selected.name)} '
    'file=${jsonEncode('test/${selected.file}')} passed=$passed '
    'reason=$reason exit=${captured.exit} '
    'events=${machine.eventCount} testDone=${machine.matchingDone} '
    'skipped=${machine.skippedDone} result=${machine.results} '
    'malformed=${machine.malformed}',
  );
  print(
    '[driver] phase=$label cwd=${appDirectory.path} '
    'argv=${jsonEncode(argv)} exit=${passed ? 0 : 1} '
    'seconds=${_seconds(stopwatch)} note=passed=$passed '
    'testDone=${machine.matchingDone} skipped=${machine.skippedDone} '
    'result=${machine.results} malformed=${machine.malformed} '
    'reason=$reason',
  );
  if (!passed) {
    stderr.writeln(
      '[driver] case=$label failed name=${jsonEncode(selected.name)} '
      'reason=$reason',
    );
  }
  return passed;
}

String _caseFailureReason(
  int exit,
  ({
    bool passed,
    bool malformed,
    int eventCount,
    int matchingDone,
    int skippedDone,
    String results,
  }) machine,
) {
  if (exit != 0) {
    return 'process-exit-$exit';
  }
  if (machine.malformed) {
    return 'malformed-machine-output';
  }
  if (machine.matchingDone == 0) {
    return 'testDone-absent';
  }
  if (machine.matchingDone > 1) {
    return 'testDone-duplicate';
  }
  if (machine.skippedDone > 0) {
    return 'skipped';
  }
  return 'result-${machine.results.isEmpty ? 'missing' : machine.results}';
}

({
  bool passed,
  bool malformed,
  int eventCount,
  int matchingDone,
  int skippedDone,
  String results,
}) _interpretMachineOutput(String output, String expectedName) {
  final names = <int, String>{};
  final done = <int, Map<String, Object?>>{};
  var malformed = false;
  var eventCount = 0;
  for (final raw in const LineSplitter().convert(output)) {
    final line = raw.trim();
    if (line.isEmpty) {
      continue;
    }
    eventCount++;
    Object? decoded;
    try {
      decoded = jsonDecode(line);
    } on FormatException {
      malformed = true;
      continue;
    }
    if (decoded is! Map) {
      // Flutter emits some protocol events as JSON arrays. They are valid
      // stream content but not test events.
      continue;
    }
    final event = Map<String, Object?>.from(decoded);
    final type = event['type'];
    if (type == 'testStart') {
      final test = event['test'];
      if (test is Map) {
        final id = test['id'];
        final name = test['name'];
        if (id is int && name is String) {
          names[id] = name;
        } else {
          malformed = true;
        }
      } else {
        malformed = true;
      }
    } else if (type == 'testDone') {
      final id = event['testID'];
      if (id is int && !done.containsKey(id)) {
        done[id] = event;
      } else {
        malformed = true;
      }
    }
  }

  final matching = <Map<String, Object?>>[];
  for (final entry in done.entries) {
    if (names[entry.key] == expectedName) {
      matching.add(entry.value);
    }
  }
  final skippedDone =
      matching.where((event) => event['skipped'] == true).length;
  final results = matching.map((event) => '${event['result']}').join(',');
  final passed = !malformed &&
      matching.length == 1 &&
      skippedDone == 0 &&
      matching.single['result'] == 'success';
  return (
    passed: passed,
    malformed: malformed,
    eventCount: eventCount,
    matchingDone: matching.length,
    skippedDone: skippedDone,
    results: results,
  );
}

Future<({int exit, String stdout, String stderr})> _runCaptured(
  String executable,
  List<String> arguments,
  Directory workingDirectory,
) async {
  try {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory.path,
      runInShell: Platform.isWindows,
    );
    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();
    final exit = await process.exitCode;
    final stdout = await stdoutFuture;
    final stderr = await stderrFuture;
    return (exit: exit, stdout: stdout, stderr: stderr);
  } on ProcessException catch (error) {
    return (exit: 127, stdout: '', stderr: '${error.message}\n');
  }
}

Future<void> _recordEnvironment(Directory root, String command) async {
  final stopwatch = Stopwatch()..start();
  final flutter = await _resolveExecutable('flutter');
  final dart = await _resolveExecutable('dart');
  final version = await _capture('flutter', ['--version', '--machine'], root);
  final revision = await _capture('git', ['rev-parse', 'HEAD'], root);
  final gitRevision =
      revision.exit == 0 ? revision.output.trim() : 'unavailable';
  final environment = <String, Object?>{
    'command': command,
    'cwd': root.path,
    'flutter': flutter,
    'dart': dart,
    'flutter_version_exit': version.exit,
    'flutter_version': version.output.trim(),
    'git_revision_exit': revision.exit,
    'git_revision': gitRevision,
    'git_repository': revision.exit == 0,
  };
  _writeEvidence(
    'environment-$command.json',
    '${const JsonEncoder.withIndent('  ').convert(environment)}\n',
  );
  print(
    '[driver] env command=$command flutter=$flutter dart=$dart '
    'flutter-version-exit=${version.exit} revision=$gitRevision',
  );
  print(
    '[driver] phase=environment cwd=${root.path} argv=[] exit=0 '
    'seconds=${_seconds(stopwatch)} note=flutter=$flutter dart=$dart '
    'revision=$gitRevision',
  );
}

Future<String> _resolveExecutable(String name) async {
  try {
    final result = await Process.run(
      Platform.isWindows ? 'where' : 'which',
      [name],
      runInShell: Platform.isWindows,
    );
    if (result.exitCode == 0) {
      final first = '${result.stdout}'.split('\n').first.trim();
      if (first.isNotEmpty) {
        return first;
      }
    }
  } on ProcessException {
    // Fall through to unavailable.
  }
  return 'unavailable';
}

Future<({int exit, String output})> _capture(
  String executable,
  List<String> arguments,
  Directory workingDirectory,
) async {
  try {
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory.path,
      runInShell: Platform.isWindows,
    );
    return (
      exit: result.exitCode,
      output: '${result.stdout}${result.stderr}',
    );
  } on ProcessException catch (error) {
    return (exit: 127, output: error.message);
  }
}

String? _evidenceRoot() {
  final value = Platform.environment['REGISTRY_EVIDENCE_DIR'];
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

void _writeEvidence(String relativePath, String content) {
  final root = _evidenceRoot();
  if (root == null) {
    return;
  }
  final file = File('$root/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

String _seconds(Stopwatch stopwatch) {
  return (stopwatch.elapsedMicroseconds / 1000000).toStringAsFixed(2);
}

bool _mergeRatingsOverride(Directory root) {
  final overrideFile = File(
    '${_packageDirectory(root, _appPackage).path}/pubspec_overrides.yaml',
  );
  final workingDirectory = overrideFile.parent;
  print(
    '[driver] phase=overrides start cwd=${workingDirectory.path} argv=[] '
    'action=merge-pubspec-overrides',
  );
  final stopwatch = Stopwatch()..start();
  var exit = 0;
  var note = '';
  try {
    final missing = _missingCheckoutFiles(root);
    if (missing.isNotEmpty) {
      exit = 1;
      note = 'missing-checkout';
      stderr.writeln(
        '[driver] overrides error=checkout incomplete; missing '
        '${missing.join(', ')}',
      );
    } else {
      note = _applyRatingsOverride(overrideFile);
    }
  } on OverrideConflict catch (error) {
    exit = 1;
    note = 'refused';
    stderr.writeln('[driver] overrides error=${error.message}');
  } on FileSystemException catch (error) {
    exit = 1;
    note = 'failed';
    stderr.writeln('[driver] overrides error=${error.message}');
  } finally {
    stopwatch.stop();
  }
  print(
    '[driver] phase=overrides cwd=${workingDirectory.path} argv=[] exit=$exit '
    'seconds=${_seconds(stopwatch)} note=$note',
  );
  return exit == 0;
}

List<String> _missingCheckoutFiles(Directory root) {
  final required = <String>[
    '${_packageDirectory(root, _appPackage).path}/pubspec.yaml',
    '${_packageDirectory(root, _ratingsPackage).path}/pubspec.yaml',
  ];
  return <String>[
    for (final path in required)
      if (!File(path).existsSync()) path,
  ];
}

String _applyRatingsOverride(File file) {
  if (!file.existsSync()) {
    file.writeAsStringSync(_newOverrideFile());
    return 'created';
  }
  final original = file.readAsStringSync();
  final merged = _mergeRatingsOverrideText(original, file.parent);
  if (merged == original) {
    return 'unchanged';
  }
  file.writeAsStringSync(merged);
  return 'merged';
}

String _newOverrideFile() {
  return 'dependency_overrides:\n'
      '  app_center_ratings_client:\n'
      '    path: $_ratingsOverridePath\n';
}

String _mergeRatingsOverrideText(String source, Directory appDirectory) {
  if (source.contains('\r')) {
    _refuse('CRLF line endings are unsupported',
        _lineAt(source, source.indexOf('\r')));
  }
  final lines = source.split('\n');
  final entries = <_OverrideEntry>[];
  var section = -1;
  var emptyFlow = false;

  void closeEntry() {
    if (entries.isEmpty) return;
    final entry = entries.last;
    if (entry.value == null) {
      throw OverrideConflict('package entry "${entry.key}" at line '
          '${entry.index + 1} must contain exactly one path or version child');
    }
  }

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final number = index + 1;
    if (line.contains('\t')) _refuse('tab characters are unsupported', number);
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    final content = _stripTrailingComment(line);
    final trimmed = content.trim();
    final indent = _indent(line);

    if (_documentMarker.hasMatch(trimmed)) {
      _refuse('YAML document markers are unsupported', number);
    }
    if (trimmed.startsWith('%')) {
      _refuse('YAML directives are unsupported', number);
    }

    if (indent == 0) {
      if (trimmed.startsWith('-')) {
        _refuse('root-level and indentless sequences are unsupported', number);
      }
      _rejectSyntax(trimmed, number, key: true);
      if (trimmed == 'dependency_overrides:' ||
          trimmed == 'dependency_overrides: {}') {
        if (section >= 0) {
          _refuse('duplicate dependency_overrides sections', number);
        }
        section = index;
        if (trimmed.endsWith('{}')) {
          emptyFlow = true;
          final stripped = _stripTrailingComment(line);
          final comment = stripped.length == line.length
              ? ''
              : line.substring(stripped.length).trim();
          lines[index] = comment.isEmpty
              ? 'dependency_overrides:'
              : 'dependency_overrides: $comment';
        }
        continue;
      }
      if (trimmed.startsWith('dependency_overrides:')) {
        final remainder =
            trimmed.substring('dependency_overrides:'.length).trim();
        _rejectSyntax(remainder, number);
        _refuse('dependency_overrides must be a block section', number);
      }
      _refuse('only dependency_overrides may appear at the top level', number);
    }

    if (section < 0) {
      _refuse('indented content before dependency_overrides', number);
    }
    if (emptyFlow) {
      _refuse('content after an empty-flow section', number);
    }
    if (indent == 2) {
      closeEntry();
      final (key, remainder) =
          _splitMapping(content.substring(2).trimRight(), number);
      _rejectSyntax(key, number, key: true);
      if (remainder.isNotEmpty) {
        _rejectSyntax(remainder, number);
        _refuse('package entry "$key" has an inline value', number);
      }
      if (!_packageName.hasMatch(key)) {
        _refuse('package entry key "$key" is not a package name', number);
      }
      if (entries.any((entry) => entry.key == key)) {
        _refuse('duplicate package entry "$key"', number);
      }
      entries.add(_OverrideEntry(index, key));
      continue;
    }
    if (indent == 4) {
      if (entries.isEmpty)
        _refuse('path child without a package entry', number);
      final entry = entries.last;
      if (entry.value != null) {
        throw OverrideConflict('package entry "${entry.key}" at line '
            '${entry.index + 1} must contain exactly one child; extra child '
            'at line $number');
      }
      final (key, raw) =
          _splitMapping(content.substring(4).trimRight(), number);
      _rejectSyntax(key, number, key: true);
      if (key != 'path' && key != 'version') {
        throw OverrideConflict('package entry "${entry.key}" at line '
            '${entry.index + 1} must contain only a path or version child; found "$key" '
            'at line $number');
      }
      entry.child = key;
      entry.value = _overrideValue(raw, number);
      continue;
    }
    _refuse('unsupported indentation or extra nesting', number);
  }
  closeEntry();

  if (section < 0) return _appendCanonical(source);

  final ratings = entries
      .where((entry) => entry.key == 'app_center_ratings_client')
      .toList();
  if (ratings.isEmpty) {
    lines.insertAll(section + 1, _ratingEntryLines);
    return lines.join('\n');
  }
  final entry = ratings.single;
  if (entry.child != 'path' || !_isRatingsPath(entry.value!, appDirectory)) {
    throw OverrideConflict('app_center_ratings_client override at line '
        '${entry.index + 1} must point to $_ratingsOverridePath');
  }
  return source;
}

String _appendCanonical(String source) {
  if (source.isEmpty) return _newOverrideFile();
  final buffer = StringBuffer(source);
  if (!source.endsWith('\n')) buffer.writeln();
  buffer.writeln();
  buffer.writeln('dependency_overrides:');
  buffer.writeln('  app_center_ratings_client:');
  buffer.writeln('    path: $_ratingsOverridePath');
  return buffer.toString();
}

Never _refuse(String reason, int line) {
  throw OverrideConflict('$reason at line $line');
}

(String, String) _splitMapping(String body, int line) {
  final colon = body.indexOf(':');
  if (colon < 0) _refuse('mapping entries must be "<key>:"', line);
  if (colon + 1 < body.length && body[colon + 1] != ' ') {
    _refuse('a space is required after ":"', line);
  }
  final key = body.substring(0, colon);
  if (key != key.trim()) _refuse('spaces before ":" are unsupported', line);
  return (key, body.substring(colon + 1).trim());
}

void _rejectSyntax(String value, int line, {bool key = false}) {
  if (key && value.isEmpty) _refuse('empty keys are unsupported', line);
  if (value.startsWith('<<')) _refuse('YAML merge keys are unsupported', line);
  if (value.startsWith('?')) _refuse('explicit keys are unsupported', line);
  if (value.startsWith('!')) _refuse('YAML tags are unsupported', line);
  if (value.startsWith('&') || value.startsWith('*')) {
    _refuse('YAML anchors and aliases are unsupported', line);
  }
  if (value.startsWith('{') || value.startsWith('[')) {
    _refuse('flow collections are unsupported', line);
  }
  if (value.startsWith('|') || value.startsWith('>')) {
    _refuse('block scalars are unsupported', line);
  }
  if (key && (value.startsWith("'") || value.startsWith('"'))) {
    _refuse('quoted keys are unsupported', line);
  }
}

String _overrideValue(String raw, int line) {
  var value = raw.trim();
  _rejectSyntax(value, line);
  if (value.startsWith("'") || value.startsWith('"')) {
    final quote = value[0];
    if (value.length < 2 || !value.endsWith(quote)) {
      _refuse('unterminated quoted path or version value', line);
    }
    value = value.substring(1, value.length - 1);
  } else if (value.contains(': ') || value.endsWith(':')) {
    _refuse('plain path or version values with mapping syntax are unsupported',
        line);
  }
  if (value.isEmpty) _refuse('empty path or version value', line);
  return value;
}

class _OverrideEntry {
  _OverrideEntry(this.index, this.key);

  final int index;
  final String key;
  String? child;
  String? value;
}

const _ratingEntryLines = <String>[
  '  app_center_ratings_client:',
  '    path: $_ratingsOverridePath',
];

String _stripTrailingComment(String line) {
  String? quote;
  for (var index = 0; index < line.length; index++) {
    final char = line[index];
    if (quote != null) {
      if (char == quote) quote = null;
      continue;
    }
    if (char == "'" || char == '"') {
      quote = char;
    } else if (char == '#' &&
        (index == 0 || line[index - 1] == ' ' || line[index - 1] == '\t')) {
      return line.substring(0, index);
    }
  }
  return line;
}

int _indent(String line) => line.length - line.trimLeft().length;

int _lineAt(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

bool _isRatingsPath(String value, Directory appDirectory) {
  return _normalizedPath(value, appDirectory.path) ==
      _normalizedPath(_ratingsOverridePath, appDirectory.path);
}

/// Resolves [value] against [base] and returns a comparable path.
///
/// This handles POSIX and Windows separators and drive letters. Windows paths
/// are compared case-insensitively, matching the file system's usual behaviour.
String _normalizedPath(String value, String base) {
  final resolved = _isAbsolutePath(value) ? value : '$base/$value';
  final windows = Platform.isWindows;
  final normalized = Uri.file(resolved, windows: windows)
      .normalizePath()
      .toFilePath(windows: windows);
  return windows ? normalized.toLowerCase() : normalized;
}

bool _isAbsolutePath(String value) {
  if (value.startsWith('/')) return true;
  if (!Platform.isWindows) return false;
  return value.startsWith(r'\') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);
}

class OverrideConflict implements Exception {
  const OverrideConflict(this.message);

  final String message;

  @override
  String toString() => message;
}
