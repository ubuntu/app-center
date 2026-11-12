import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:debconf_frontend/debconf_frontend.dart';
import 'package:flutter_test/flutter_test.dart';

/// Talks to a [DebconfFrontend] like debconf's passthrough frontend does.
class FakeDebconf {
  FakeDebconf._(this._socket, this._replies);

  static Future<FakeDebconf> connect(String path) async {
    final socket = await Socket.connect(
      InternetAddress(path, type: InternetAddressType.unix),
      0,
    );
    final replies = utf8.decoder.bind(socket).transform(const LineSplitter());
    return FakeDebconf._(socket, StreamIterator(replies));
  }

  final Socket _socket;
  final StreamIterator<String> _replies;

  /// Sends [command] and returns the reply, or null if the frontend hung up.
  Future<String?> talk(String command) async {
    _socket.write('$command\n');
    return await _replies.moveNext() ? _replies.current : null;
  }

  Future<void> close() => _socket.close();
}

void main() {
  late Directory tempDir;
  late DebconfFrontend frontend;
  late List<DebconfPrompt> prompts;
  late DebconfDialogResult Function(DebconfPrompt prompt) answer;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('debconf_frontend_test');
    prompts = [];
    answer = (prompt) => DebconfAnswered({
      for (final question in prompt.questions) question.name: question.value,
    });
    frontend = await DebconfFrontend.bind(
      '${tempDir.path}/debconf.socket',
      onPrompt: (prompt) async {
        prompts.add(prompt);
        return answer(prompt);
      },
    );
  });

  tearDown(() async {
    await frontend.close();
    await tempDir.delete(recursive: true);
  });

  test('asks the questions of a GO and answers GET', () async {
    final debconf = await FakeDebconf.connect(frontend.path);
    addTearDown(debconf.close);
    answer = (_) => const DebconfAnswered({'foo/name': 'Alice'});

    for (final command in [
      'TITLE Configuring foo',
      'DATA foo/name type string',
      'DATA foo/name description Your name:',
      r'DATA foo/name extended_description First.\n\nSecond paragraph.',
      'SET foo/name Bob',
    ]) {
      expect(await debconf.talk(command), '0 ok');
    }
    expect(await debconf.talk('INPUT high foo/name'), startsWith('0 '));
    expect(await debconf.talk('GO'), '0 ok');
    expect(await debconf.talk('GET foo/name'), '0 Alice');

    final prompt = prompts.single;
    expect(prompt.title, 'Configuring foo');
    expect(prompt.canGoBack, isFalse);
    final question = prompt.questions.single;
    expect(question.name, 'foo/name');
    expect(question.type, DebconfQuestionType.string);
    expect(question.description, 'Your name:');
    expect(question.extendedDescription, 'First.\n\nSecond paragraph.');
    expect(question.value, 'Bob');
  });

  test('splits choices like debconf', () async {
    final debconf = await FakeDebconf.connect(frontend.path);
    addTearDown(debconf.close);

    await debconf.talk('DATA foo/zone type select');
    await debconf.talk(r'DATA foo/zone choices Europe, America\, North, Asia');
    await debconf.talk('INPUT high foo/zone');
    await debconf.talk('GO');

    expect(prompts.single.questions.single.choices, [
      'Europe',
      'America, North',
      'Asia',
    ]);
  });

  test('goes back if the script supports it', () async {
    final debconf = await FakeDebconf.connect(frontend.path);
    addTearDown(debconf.close);
    answer = (_) => const DebconfWentBack();

    expect(await debconf.talk('CAPB backup'), '0 backup');
    expect(await debconf.talk('CAPB'), '0 backup');
    await debconf.talk('DATA foo/ok type boolean');
    await debconf.talk('INPUT high foo/ok');

    expect(await debconf.talk('GO'), '30 backup');
    expect(prompts.single.canGoBack, isTrue);
  });

  test('hangs up when the questions are cancelled', () async {
    final debconf = await FakeDebconf.connect(frontend.path);
    addTearDown(debconf.close);
    answer = (_) => const DebconfCancelled();

    await debconf.talk('DATA foo/ok type boolean');
    await debconf.talk('INPUT high foo/ok');

    expect(await debconf.talk('GO'), isNull);
  });

  test('answers other commands without asking', () async {
    final debconf = await FakeDebconf.connect(frontend.path);
    addTearDown(debconf.close);

    expect(await debconf.talk('X_PING'), '0 pong');
    expect(await debconf.talk('PROGRESS START 0 10 foo/progress'), '0 ok');
    expect(await debconf.talk('INPUT high foo/unknown'), startsWith('0 '));
    expect(await debconf.talk('GO'), '0 ok');
    expect(await debconf.talk('GET foo/unknown'), '0 ');
    expect(await debconf.talk('FOO'), '20 Unsupported command');
    expect(prompts, isEmpty);
  });

  test('replaces a stale socket and removes it when closed', () async {
    final path = '${tempDir.path}/stale.socket';
    File(path).writeAsStringSync('');

    final other = await DebconfFrontend.bind(
      path,
      onPrompt: (_) async => const DebconfCancelled(),
    );
    await other.close();

    expect(File(path).existsSync(), isFalse);
  });
}
