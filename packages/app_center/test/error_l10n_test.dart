import 'package:app_center/error/error.dart';
import 'package:app_center/error/error_l10n.dart';
import 'package:app_center/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  group('SnapdException', () {
    final testCases = <({
      String name,
      SnapdException exception,
      String Function(AppLocalizations l10n) expectedTitle,
      String Function(AppLocalizations l10n) expectedBody,
      String Function(AppLocalizations l10n) expectedActionLabel,
      List<ErrorAction> expectedActions,
    })>[
      (
        name: 'network timeout',
        exception: SnapdException(kind: 'network-timeout', message: 'message'),
        expectedTitle: (l10n) => l10n.errorViewNetworkErrorTitle,
        expectedBody: (l10n) => l10n.errorViewNetworkErrorDescription,
        expectedActionLabel: (l10n) => l10n.errorViewNetworkErrorAction,
        expectedActions: [ErrorAction.retry],
      ),
      (
        name: 'too many requests',
        exception: SnapdException(message: 'too many requests'),
        expectedTitle: (l10n) => l10n.errorViewUnknownErrorTitle,
        expectedBody: (l10n) => l10n.errorViewServerErrorDescription,
        expectedActionLabel: (l10n) => l10n.errorViewServerErrorAction,
        expectedActions: [ErrorAction.checkStatus],
      ),
      (
        name: 'running apps',
        exception: SnapdException(
          kind: 'error',
          message:
              'cannot refresh "testsnap": snap "testsnap" has running apps (testapp)',
        ),
        expectedTitle: (l10n) => l10n.managePageUpdatesFailed(1),
        expectedBody: (l10n) => l10n.snapdExceptionRunningApps('testsnap'),
        expectedActionLabel: (l10n) => l10n.errorViewUnknownErrorAction,
        expectedActions: [],
      ),
    ];

    for (final testCase in testCases) {
      testWidgets(testCase.name, (tester) async {
        await tester.pumpApp((context) => const Scaffold());
        final message = ErrorMessage.fromObject(testCase.exception);
        expect(
          message.title(tester.l10n),
          testCase.expectedTitle(tester.l10n),
        );
        expect(
          message.body(tester.l10n),
          testCase.expectedBody(tester.l10n),
        );
        expect(
          message.actionLabel(tester.l10n),
          testCase.expectedActionLabel(tester.l10n),
        );
        expect(message.actions, testCase.expectedActions);
      });
    }
  });
}
