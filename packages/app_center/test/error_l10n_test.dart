import 'package:app_center/error/error.dart';
import 'package:app_center/error/error_l10n.dart';
import 'package:app_center/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

/// A simple structure common amongst test cases.
class _TestCase {
  _TestCase({
    required this.name,
    required this.exception,
    required this.expectedTitle,
    required this.expectedBody,
    required this.expectedActionLabel,
    required this.expectedActions,
  });

  final String name;
  final SnapdException exception;
  final String Function(AppLocalizations l10n) expectedTitle;
  final String Function(AppLocalizations l10n) expectedBody;
  final String Function(AppLocalizations l10n) expectedActionLabel;
  final List<ErrorAction> expectedActions;
}

void main() {
  group('SnapdException', () {
    group('fromObject correctly transforms:', () {
      final testCases = <_TestCase>[
        _TestCase(
          name: 'network timeout',
          exception:
              SnapdException(kind: 'network-timeout', message: 'message'),
          expectedTitle: (l10n) => l10n.errorViewNetworkErrorTitle,
          expectedBody: (l10n) => l10n.errorViewNetworkErrorDescription,
          expectedActionLabel: (l10n) => l10n.errorViewNetworkErrorAction,
          expectedActions: [ErrorAction.retry],
        ),
        _TestCase(
          name: 'too many requests',
          exception: SnapdException(message: 'too many requests'),
          expectedTitle: (l10n) => l10n.errorViewUnknownErrorTitle,
          expectedBody: (l10n) => l10n.errorViewServerErrorDescription,
          expectedActionLabel: (l10n) => l10n.errorViewServerErrorAction,
          expectedActions: [ErrorAction.checkStatus],
        ),
        _TestCase(
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
        _TestCase(
          name: 'persistent network error',
          exception: SnapdException(
            // Intentionally trigger the pattern match instead of short-circuiting
            // at the kind check within the .fromObject call within the test.
            kind: 'error',
            message: 'persistent network error',
          ),
          expectedActions: [ErrorAction.retry],
          expectedTitle: (l10n) => l10n.errorViewNetworkErrorTitle,
          expectedBody: (l10n) => l10n.errorViewNetworkErrorDescription,
          expectedActionLabel: (l10n) => l10n.errorViewNetworkErrorAction,
        ),
      ];

      for (final testCase in testCases) {
        testWidgets(testCase.name, (tester) async {
          await tester.pumpApp((context) => const Scaffold());

          expect(
            ErrorMessage.fromObject(testCase.exception),
            isA<ErrorMessage>()
                .having(
                  (e) => e.title(tester.l10n),
                  'has expected title',
                  testCase.expectedTitle(tester.l10n),
                )
                .having(
                  (e) => e.body(tester.l10n),
                  'has expected body',
                  testCase.expectedBody(tester.l10n),
                )
                .having(
                  (e) => e.actionLabel(tester.l10n),
                  'has expected label',
                  testCase.expectedTitle(tester.l10n),
                )
                .having(
                  (e) => e.actions,
                  'has expected actions',
                  testCase.expectedActions,
                ),
          );
        });
      }
    });

    group('consolidates via', () {
      final expectedErrors = <String, SnapdException>{
        'testsnap': SnapdException(
          kind: 'error',
          message:
              'cannot refresh "testsnap": snap "testsnap" has running apps (testapp)',
        ),
        'testsnap-1': SnapdException(message: 'too many requests'),
        'testsnap-2':
            SnapdException(kind: 'network-timeout', message: 'message'),
      };

      testWidgets('via fromObject when provided a `ConsolidatedSnapdException`',
          (tester) async {
        await tester.pumpApp((context) => const Scaffold());
        expect(
          ErrorMessage.fromObject(ConsolidatedSnapdException(expectedErrors)),
          _consolidationExpectations(
            tester.l10n,
            expectedErrors.length,
            '• testsnap\n',
          ),
        );
      });
      testWidgets('fromMap', (tester) async {
        await tester.pumpApp((context) => const Scaffold());
        expect(
          ErrorMessage.fromMap(expectedErrors),
          _consolidationExpectations(
            tester.l10n,
            expectedErrors.length,
            '• testsnap\n',
          ),
        );
      });
    });
  });
}

/// Defines
TypeMatcher<ErrorMessageConsolidated> _consolidationExpectations(
        AppLocalizations l10n, int expectedLength, String apps) =>
    isA<ErrorMessageConsolidated>()
        .having(
          (e) => e.errors,
          'has the expected message count',
          hasLength(expectedLength),
        )
        .having(
          (e) => e.body(l10n),
          'has expected body message',
          l10n.managePageUpdatesFailedBody(
            l10n.snapdExceptionRunningApps(apps),
          ),
        )
        .having(
          (e) => e.title(l10n),
          'has the expected tittle',
          l10n.managePageUpdatesFailed(expectedLength),
        )
        .having(
          (e) => e.actionLabel(l10n),
          'has expected error label',
          l10n.errorViewUnknownErrorTitle,
        )
        .having((e) => e.actions, 'has expected actions', [
      ErrorAction.retry,
      ErrorAction.checkStatus,
    ]);
