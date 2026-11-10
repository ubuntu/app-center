import 'package:debconf_frontend/debconf_frontend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:yaru/yaru.dart';

Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
  const MaterialApp(
    localizationsDelegates: GlobalUbuntuLocalizations.delegates,
    home: Scaffold(),
  ),
);

Future<DebconfDialogResult> showQuestions(
  WidgetTester tester,
  List<DebconfQuestion> questions, {
  bool canGoBack = false,
}) => showDebconfDialog(
  tester.element(find.byType(Scaffold)),
  title: 'Configuring matlab-support',
  questions: questions,
  canGoBack: canGoBack,
);

Matcher answered(Map<String, String> values) =>
    isA<DebconfAnswered>().having((result) => result.values, 'values', values);

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

const _note = DebconfQuestion(
  name: 'matlab-support/note',
  type: DebconfQuestionType.note,
  description: 'MATLAB was not found',
);

void main() {
  testWidgets('string questions return the entered text', (tester) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'matlab-support/mlpath',
        type: DebconfQuestionType.string,
        description: 'Location of the MATLAB installation:',
        extendedDescription: 'Enter the directory where MATLAB is installed.',
        value: '/usr/local/MATLAB',
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Configuring matlab-support'), findsOneWidget);
    expect(find.text('Location of the MATLAB installation:'), findsOneWidget);
    expect(
      find.text('Enter the directory where MATLAB is installed.'),
      findsOneWidget,
    );
    expect(find.text('/usr/local/MATLAB'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '/opt/matlab');
    await tapAndSettle(tester, find.text('Continue'));

    expect(await result, answered({'matlab-support/mlpath': '/opt/matlab'}));
  });

  testWidgets('password questions hide the text', (tester) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'mysql-server/root_password',
        type: DebconfQuestionType.password,
        description: 'New password for the MySQL "root" user:',
      ),
    ]);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, true);

    await tester.enterText(find.byType(TextField), 'secret');
    await tapAndSettle(tester, find.text('Continue'));

    expect(await result, answered({'mysql-server/root_password': 'secret'}));
  });

  testWidgets('boolean questions are checkboxes', (tester) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'libraries/restart-without-asking',
        type: DebconfQuestionType.boolean,
        description: 'Restart services during package upgrades?',
        value: 'false',
      ),
    ]);
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byType(CheckboxListTile));
    await tapAndSettle(tester, find.text('Continue'));

    expect(
      await result,
      answered({'libraries/restart-without-asking': 'true'}),
    );
  });

  testWidgets('select questions with few choices are radio buttons', (
    tester,
  ) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'keyboard-configuration/layout',
        type: DebconfQuestionType.select,
        description: 'Keyboard layout:',
        choices: ['English (US)', 'German', 'French'],
        value: 'German',
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(RadioListTile<String>), findsNWidgets(3));

    await tapAndSettle(tester, find.text('French'));
    await tapAndSettle(tester, find.text('Continue'));

    expect(await result, answered({'keyboard-configuration/layout': 'French'}));
  });

  testWidgets('select questions default to the first choice', (tester) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'keyboard-configuration/layout',
        type: DebconfQuestionType.select,
        description: 'Keyboard layout:',
        choices: ['English (US)', 'German'],
      ),
    ]);
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text('Continue'));

    expect(
      await result,
      answered({'keyboard-configuration/layout': 'English (US)'}),
    );
  });

  testWidgets('select questions with many choices are dropdowns', (
    tester,
  ) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'tzdata/Areas',
        type: DebconfQuestionType.select,
        description: 'Geographic area:',
        choices: [
          'Africa',
          'America',
          'Antarctica',
          'Arctic',
          'Asia',
          'Atlantic',
          'Australia',
          'Europe',
        ],
        value: 'Europe',
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(RadioListTile<String>), findsNothing);

    await tapAndSettle(tester, find.text('Europe'));
    await tapAndSettle(tester, find.text('Asia'));
    await tapAndSettle(tester, find.text('Continue'));

    expect(await result, answered({'tzdata/Areas': 'Asia'}));
  });

  testWidgets('multiselect answers keep the order of the choices', (
    tester,
  ) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'locales/locales_to_be_generated',
        type: DebconfQuestionType.multiselect,
        description: 'Locales to be generated:',
        choices: [
          'de_DE.UTF-8 UTF-8',
          'en_US.UTF-8 UTF-8',
          'fr_FR.UTF-8 UTF-8',
        ],
        value: 'de_DE.UTF-8 UTF-8, fr_FR.UTF-8 UTF-8',
      ),
    ]);
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text('de_DE.UTF-8 UTF-8'));
    await tapAndSettle(tester, find.text('en_US.UTF-8 UTF-8'));
    await tapAndSettle(tester, find.text('Continue'));

    expect(
      await result,
      answered({
        'locales/locales_to_be_generated':
            'en_US.UTF-8 UTF-8, fr_FR.UTF-8 UTF-8',
      }),
    );
  });

  testWidgets('notes, errors and texts are shown together', (tester) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [
      DebconfQuestion(
        name: 'matlab-support/updated',
        type: DebconfQuestionType.note,
        description: 'Configuration updated',
        extendedDescription: 'Your previous settings were kept.',
      ),
      DebconfQuestion(
        name: 'matlab-support/invalid',
        type: DebconfQuestionType.error,
        description: 'The directory does not exist.',
      ),
      DebconfQuestion(
        name: 'matlab-support/license',
        type: DebconfQuestionType.text,
        description: 'License',
        extendedDescription: 'MATLAB needs a valid license.',
        value: 'seen',
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(YaruInfoBox), findsNWidgets(2));
    expect(find.byType(TextField), findsNothing);
    for (final text in [
      'Configuration updated',
      'Your previous settings were kept.',
      'The directory does not exist.',
      'License',
      'MATLAB needs a valid license.',
    ]) {
      expect(find.text(text), findsOneWidget);
    }

    await tapAndSettle(tester, find.text('Continue'));

    expect(
      await result,
      answered({
        'matlab-support/updated': '',
        'matlab-support/invalid': '',
        'matlab-support/license': 'seen',
      }),
    );
  });

  testWidgets('back is only offered if the script supports it', (
    tester,
  ) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [_note]);
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsNothing);

    await tapAndSettle(tester, find.text('Continue'));
    expect(await result, isA<DebconfAnswered>());

    final backResult = showQuestions(tester, const [_note], canGoBack: true);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Back'));

    expect(await backResult, isA<DebconfWentBack>());
  });

  testWidgets('cancel and close cancel the setup', (tester) async {
    await pumpApp(tester);
    final result = showQuestions(tester, const [_note]);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Cancel'));

    expect(await result, isA<DebconfCancelled>());

    final closeResult = showQuestions(tester, const [_note]);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byType(YaruWindowControl));

    expect(await closeResult, isA<DebconfCancelled>());
  });
}
