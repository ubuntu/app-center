// Flutter Customer Test Registry driver for App Center.
// Usage: dart scripts/customer_testing.dart <prepare|test>

import 'dart:convert';
import 'dart:io';

const _appPackage = 'packages/app_center';
const _melosConfigName = 'melos.yaml';
const _manifestPath = 'customer_tests.json';
const _evidenceDirectoryVariable = 'REGISTRY_EVIDENCE_DIR';
final _dart = Platform.resolvedExecutable;
const _allowedArgs = ['prepare', 'test'];

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 || !_allowedArgs.contains(arguments.single)) {
    final usageArgs = _allowedArgs.join('|');
    stderr.writeln(
      'Usage: dart scripts/customer_testing.dart <$usageArgs>',
    );
    if (arguments.isNotEmpty) {
      stderr.writeln('Unknown arguments: ${arguments.join(' ')}');
    }
    exitCode = 64;
    return;
  }

  final command = arguments.single;
  final root = Directory.current;
  print('[customer-testing] command=$command root=${root.path}');
  await _recordEnvironment(root, command);

  var succeeded = false;
  if (command == 'prepare') {
    succeeded = await _prepare(root);
  } else {
    succeeded = await _test(root);
  }
  print('[customer-testing] command=$command exit=${succeeded ? 0 : 1}');
  if (!succeeded) {
    exitCode = 1;
  }
}

/// Prepares a disposable checkout for running customer tests.
Future<bool> _prepare(Directory root) async {
  final melosPubGetOk = await _runPhase(
    label: 'melos-pub-get',
    executable: _dart,
    arguments: const ['pub', 'get', '--enforce-lockfile'],
    workingDirectory: root,
  );
  if (!melosPubGetOk) {
    return false;
  }

  final workspace = _MelosWorkspace.load(root);

  return _withMelos(root, () async {
    if (!await workspace.bootstrap()) {
      return false;
    }
    return _runCodegen(root);
  });
}

/// Runs the selected customer tests and reports any failures.
Future<bool> _test(Directory root) async {
  final codegenOk = await _withMelos(root, () => _runCodegen(root));
  if (!codegenOk) {
    return false;
  }

  final selectedCases = _TestManifest.load(root, _manifestPath).cases;

  final appCenterPkg = Directory('${root.path}/$_appPackage');
  final failures = <String>[];
  final concurrency = Platform.numberOfProcessors.clamp(1, 4);
  var nextIndex = 0;
  Future<void> worker() async {
    while (nextIndex < selectedCases.length) {
      final selected = selectedCases[nextIndex++];
      final fileName = selected.file.split('/').last;
      final testName = selected.name.toLowerCase().replaceAll(' ', '-');
      final label = '$fileName:$testName';
      final failureReason =
          await _runSelectedCase(label, selected, appCenterPkg);
      if (failureReason != null) {
        failures.add('${selected.file}: ${selected.name} ($failureReason)');
      }
    }
  }

  await Future.wait(List.generate(concurrency, (_) => worker()));

  print(
    '[customer-testing] summary command=test total=${selectedCases.length} '
    'passed=${selectedCases.length - failures.length} '
    'failed=${failures.length}',
  );
  failures.sort();
  for (final failure in failures) {
    stderr.writeln('[customer-testing] failed case=$failure');
  }
  return failures.isEmpty;
}

/// The workspace root and temporarily relaxed `melos.yaml` contents.
class _MelosWorkspace {
  const _MelosWorkspace({
    required this.root,
    required this.configFile,
    required this.originalBytes,
  });

  final Directory root;
  final File configFile;
  final List<int> originalBytes;

  /// Loads `melos.yaml` below [root].
  static _MelosWorkspace load(Directory root) {
    final configFile = File('${root.path}/$_melosConfigName');
    final originalBytes = configFile.readAsBytesSync();

    return _MelosWorkspace(
      root: root,
      configFile: configFile,
      originalBytes: originalBytes,
    );
  }

  /// Bootstraps with a temporarily relaxed lockfile setting and always restores
  /// the original `melos.yaml` bytes, including when bootstrap fails to start.
  Future<bool> bootstrap() async {
    var bootstrapOk = false;
    try {
      if (!_updateMelosConfig()) {
        return false;
      }
      bootstrapOk = await _runMelos(root, 'bootstrap', const ['bootstrap']);
    } finally {
      _restore();
    }

    if (!bootstrapOk) {
      stderr.writeln('[customer-testing] prepare error=bootstrap failed');
      return false;
    }
    return true;
  }

  /// Temporarily disables lockfile enforcement so Melos can link local packages.
  bool _updateMelosConfig() {
    final content = utf8.decode(originalBytes);
    final pattern = RegExp(
      r'^(\s*enforceLockfile:\s*)true(\s*(?:#.*)?)$',
      multiLine: true,
    );
    final matches = pattern.allMatches(content).toList();
    if (matches.length != 1) {
      stderr.writeln(
        '[customer-testing] prepare error=$_melosConfigName must contain '
        'exactly one enforceLockfile: true setting',
      );
      return false;
    }
    final match = matches.single;
    final relaxed = content.replaceRange(
      match.start,
      match.end,
      '${match.group(1)}false${match.group(2) ?? ''}',
    );
    configFile.writeAsStringSync(relaxed, flush: true);
    return true;
  }

  /// Restores the original `melos.yaml` contents.
  void _restore() {
    configFile.writeAsBytesSync(originalBytes, flush: true);
  }
}

/// Parsed customer test manifest.
class _TestManifest {
  const _TestManifest._(this.cases);

  /// Selected test cases from the manifest.
  final List<_TestCase> cases;

  /// Loads and decodes the customer test manifest from disk.
  factory _TestManifest.load(Directory root, String manifestPath) {
    final manifestFile = File('${root.path}/$manifestPath');
    final decoded =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, Object?>;
    final rawTests = decoded['tests'] as Map<String, Object?>;
    final cases = <_TestCase>[];
    for (final MapEntry(key: path, value: testCases) in rawTests.entries) {
      for (final testName in testCases as List<Object?>) {
        cases.add(
          _TestCase(
            file: path.substring('$_appPackage/'.length),
            name: testName as String,
          ),
        );
      }
    }
    print(
      '[customer-testing] manifest path=$manifestPath files=${rawTests.length} '
      'cases=${cases.length}',
    );
    return _TestManifest._(cases);
  }
}

/// One selected case from the customer-test manifest.
class _TestCase {
  const _TestCase({required this.file, required this.name});

  final String file;
  final String name;
}

/// Runs a single customer test case and returns `null` on pass or a failure reason.
Future<String?> _runSelectedCase(
  String label,
  _TestCase selected,
  Directory appDirectory,
) async {
  final testFilePath = selected.file;
  final arguments = <String>[
    'test',
    '--no-pub',
    '--machine',
    '--name',
    '^${RegExp.escape(selected.name)}\$',
    testFilePath,
  ];
  final argv = <String>['flutter', ...arguments];
  print(
    '[customer-testing] phase=$label start cwd=${appDirectory.path} '
    'argv=${jsonEncode(argv)}',
  );
  final stopwatch = Stopwatch()..start();
  final captured = await _runCaptured('flutter', arguments, appDirectory);
  stopwatch.stop();

  final machine = _interpretMachineOutput(captured.stdout, selected.name);
  final reason = _inferCasePassFailReason(captured.exit, machine);
  final passed = reason == 'passed';

  _writeEvidence('cases/$label.stdout.log', captured.stdout);
  _writeEvidence('cases/$label.stderr.log', captured.stderr);
  final hasEvidenceDir =
      (Platform.environment[_evidenceDirectoryVariable] ?? '').isNotEmpty;
  if (!passed && !hasEvidenceDir) {
    _writeRawStream(label, 'stdout', captured.stdout);
    _writeRawStream(label, 'stderr', captured.stderr);
  }

  print(
    '[customer-testing] case=$label name=${jsonEncode(selected.name)} '
    'file=${jsonEncode(selected.file)} passed=$passed '
    'reason=$reason exit=${captured.exit} '
    'events=${machine.eventCount} testDone=${machine.matchingDone} '
    'skipped=${machine.skippedDone} result=${machine.results} '
    'malformed=${machine.malformed}',
  );
  print(
    '[customer-testing] phase=$label cwd=${appDirectory.path} '
    'argv=${jsonEncode(argv)} exit=${passed ? 0 : 1} '
    'seconds=${_formatSeconds(stopwatch)} note=passed=$passed '
    'testDone=${machine.matchingDone} skipped=${machine.skippedDone} '
    'result=${machine.results} malformed=${machine.malformed} '
    'reason=$reason',
  );
  if (!passed) {
    stderr.writeln(
      '[customer-testing] case=$label failed name=${jsonEncode(selected.name)} '
      'reason=$reason',
    );
    return reason;
  }
  return null;
}

void _writeRawStream(String label, String stream, String content) {
  stderr.writeln('[customer-testing] case=$label raw-machine-$stream-begin');
  stderr.write(content);
  stderr.writeln('[customer-testing] case=$label raw-machine-$stream-end');
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

typedef _MachineOutput = ({
  int eventCount,
  int matchingDone,
  int skippedDone,
  List<String> results,
  int malformed,
});

/// Checks Flutter's machine-readable test output (NDJSON) for a single non-skipped pass.
/// See: https://github.com/dart-lang/test/blob/master/pkgs/test/doc/json_reporter.md
_MachineOutput _interpretMachineOutput(String stdoutText, String expectedName) {
  final matchingIds = <int>{};
  var eventCount = 0;
  var matchingDone = 0;
  var skippedDone = 0;
  var malformed = 0;
  final results = <String>[];

  for (final rawLine in const LineSplitter().convert(stdoutText)) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      continue;
    }

    final Map<String, Object?> event;
    try {
      final decoded = jsonDecode(line);
      if (decoded is! Map<String, Object?>) {
        malformed++;
        continue;
      }
      event = decoded;
    } on FormatException {
      malformed++;
      continue;
    }

    eventCount++;
    switch (event) {
      case {
          'type': 'testStart',
          'test': {'id': final int id, 'name': final String name} &&
              final Map<String, Object?> test,
        }:
        final metadata = test['metadata'];
        final hidden =
            metadata is Map<String, Object?> && metadata['hidden'] == true;
        if (!hidden && name == expectedName) {
          matchingIds.add(id);
        }
      case {'type': 'testDone', 'testID': final int testId}:
        if (event['hidden'] == true || !matchingIds.contains(testId)) {
          continue;
        }
        matchingDone++;
        if (event['skipped'] == true) {
          skippedDone++;
        }
        if (event['result'] case final String result) {
          results.add(result);
        }
    }
  }

  return (
    eventCount: eventCount,
    matchingDone: matchingDone,
    skippedDone: skippedDone,
    results: results,
    malformed: malformed,
  );
}

/// Summarizes why a customer test case failed.
String _inferCasePassFailReason(int exitCode, _MachineOutput machine) {
  if (machine.matchingDone == 0) {
    return 'no-matching-test-done';
  }
  if (machine.matchingDone > 1) {
    return 'multiple-matching-tests';
  }
  if (machine.skippedDone > 0) {
    return 'skipped';
  }
  if (machine.results.isEmpty || machine.results.single != 'success') {
    return 'result-${machine.results.isEmpty ? 'missing' : machine.results.single}';
  }
  if (exitCode != 0) {
    return 'nonzero-exit';
  }
  return 'passed';
}

/// Runs an action with the repository's locked Melos temporarily activated.
Future<bool> _withMelos(Directory root, Future<bool> Function() body) async {
  final melosPath = _melosPackagePath(root);
  if (melosPath == null) {
    return false;
  }
  final activateOk = await _runPhase(
    label: 'melos-activate',
    executable: _dart,
    arguments: ['pub', 'global', 'activate', '--source', 'path', melosPath],
    workingDirectory: root,
  );
  if (!activateOk) {
    return false;
  }
  try {
    return await body();
  } finally {
    await _runPhase(
      label: 'melos-deactivate',
      executable: _dart,
      arguments: const ['pub', 'global', 'deactivate', 'melos'],
      workingDirectory: root,
    );
  }
}

/// Locates the resolved Melos package path from the Dart package config.
String? _melosPackagePath(Directory root) {
  final file = File('${root.path}/.dart_tool/package_config.json');
  if (!file.existsSync()) {
    stderr.writeln(
      '[customer-testing] error=missing ${file.path}; run dart pub get first',
    );
    return null;
  }
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  final packages = decoded['packages'] as List<Object?>? ?? const [];
  for (final entry in packages) {
    if (entry is Map<String, Object?> && entry['name'] == 'melos') {
      final rootUri = entry['rootUri'] as String?;
      if (rootUri != null) {
        return file.parent.uri.resolve(rootUri).toFilePath();
      }
    }
  }
  stderr.writeln('[customer-testing] error=melos not found in ${file.path}');
  return null;
}

Future<bool> _runCodegen(Directory root) async {
  final generateOk = await _runMelos(root, 'generate', const [
    'run',
    'generate',
  ]);
  if (!generateOk) {
    return false;
  }
  return _runMelos(root, 'gen-l10n', const ['run', 'gen-l10n']);
}

/// Runs a Melos command using the Dart SDK on `PATH`.
Future<bool> _runMelos(
  Directory root,
  String label,
  List<String> arguments,
) {
  final environment = Map<String, String>.from(Platform.environment);
  environment['MELOS_SDK_PATH'] = 'auto';
  final pubCache =
      environment['PUB_CACHE'] ?? '${environment['HOME'] ?? ''}/.pub-cache';
  environment['PATH'] = '$pubCache/bin:${environment['PATH'] ?? ''}';
  return _runPhase(
    label: label,
    executable: _dart,
    arguments: <String>['run', 'melos', '--sdk-path', 'auto', ...arguments],
    workingDirectory: root,
    environment: environment,
  );
}

/// Runs a logged build or setup step with inherited stdio.
Future<bool> _runPhase({
  required String label,
  required String executable,
  required List<String> arguments,
  required Directory workingDirectory,
  Map<String, String>? environment,
}) async {
  final argv = <String>[executable, ...arguments];
  print(
    '[customer-testing] phase=$label start cwd=${workingDirectory.path} '
    'argv=${jsonEncode(argv)}',
  );
  final stopwatch = Stopwatch()..start();
  var exit = 1;
  try {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory.path,
      environment: environment,
      mode: ProcessStartMode.inheritStdio,
    );
    exit = await process.exitCode;
  } on ProcessException catch (error) {
    exit = 127;
    stderr.writeln(
      '[customer-testing] phase=$label process-error=${error.message}',
    );
  } finally {
    stopwatch.stop();
  }
  print(
    '[customer-testing] phase=$label cwd=${workingDirectory.path} '
    'argv=${jsonEncode(argv)} exit=$exit seconds=${_formatSeconds(stopwatch)}',
  );
  return exit == 0;
}

/// Records the active Dart, Flutter, and Git environment for diagnostics.
Future<void> _recordEnvironment(Directory root, String command) async {
  final stopwatch = Stopwatch()..start();
  final dart = _dart;
  final version = await _capture(
    'flutter',
    const ['--version', '--machine'],
    root,
  );
  final revision = await _capture('git', const ['rev-parse', 'HEAD'], root);
  final gitRevision =
      revision.exit == 0 ? revision.output.trim() : 'unavailable';
  final environment = <String, Object?>{
    'command': command,
    'cwd': root.path,
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
    '[customer-testing] env command=$command dart=$dart '
    'flutter-version-exit=${version.exit} revision=$gitRevision',
  );
  print(
    '[customer-testing] phase=environment-$command cwd=${root.path} argv=[] '
    'exit=0 seconds=${_formatSeconds(stopwatch)} note=dart=$dart '
    'revision=$gitRevision',
  );
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
    );
    return (
      exit: result.exitCode,
      output: '${result.stdout}${result.stderr}',
    );
  } on ProcessException catch (error) {
    return (exit: 127, output: error.message);
  }
}

String _formatSeconds(Stopwatch stopwatch) {
  return (stopwatch.elapsedMicroseconds / 1000000).toStringAsFixed(2);
}

void _writeEvidence(String relativePath, String content) {
  final root = Platform.environment[_evidenceDirectoryVariable];
  if (root == null || root.isEmpty) {
    return;
  }
  final file = File('$root/$relativePath');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}
