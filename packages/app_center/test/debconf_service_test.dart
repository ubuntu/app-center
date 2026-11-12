import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_center/packagekit/debconf_service.dart';
import 'package:debconf_frontend/debconf_frontend.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asks one question like debconf does and returns the reply to its GET.
Future<String?> askName(String socketPath) async {
  final socket = await Socket.connect(
    InternetAddress(socketPath, type: InternetAddressType.unix),
    0,
  );
  final replies = StreamIterator(
    utf8.decoder.bind(socket).transform(const LineSplitter()),
  );
  Future<String?> talk(String command) async {
    socket.write('$command\n');
    return await replies.moveNext() ? replies.current : null;
  }

  for (final command in [
    'DATA foo/name type string',
    'SET foo/name Bob',
    'INPUT high foo/name',
    'GO',
  ]) {
    await talk(command);
  }
  final reply = await talk('GET foo/name');
  await socket.close();
  return reply;
}

void main() {
  late Directory runtimeDir;

  setUp(() async {
    runtimeDir = await Directory.systemTemp.createTemp('debconf_service_test');
  });

  tearDown(() => runtimeDir.delete(recursive: true));

  test('listens in the runtime dir', () async {
    final service = DebconfService(runtimeDir: runtimeDir.path);

    final path = await service.socketPath();
    expect(path, '${runtimeDir.path}/app-center-debconf-$pid.socket');
    expect(await service.socketPath(), path);
    expect(
      FileSystemEntity.typeSync(path!),
      FileSystemEntityType.unixDomainSock,
    );

    await service.dispose();
    expect(FileSystemEntity.typeSync(path), FileSystemEntityType.notFound);
  });

  test('has no socket if it cannot listen', () async {
    final service = DebconfService(runtimeDir: '${runtimeDir.path}/missing');
    addTearDown(service.dispose);

    expect(await service.socketPath(), isNull);
  });

  test('answers with the defaults while nobody listens', () async {
    final service = DebconfService(runtimeDir: runtimeDir.path);
    addTearDown(service.dispose);

    expect(await askName((await service.socketPath())!), '0 Bob');
  });

  test('forwards questions to listeners', () async {
    final service = DebconfService(runtimeDir: runtimeDir.path);
    addTearDown(service.dispose);
    final requests = <DebconfRequest>[];
    service.requests.listen((request) {
      requests.add(request);
      request.answer(const DebconfAnswered({'foo/name': 'Alice'}));
    });

    expect(await askName((await service.socketPath())!), '0 Alice');
    expect(requests.single.prompt.questions.single.name, 'foo/name');
  });
}
