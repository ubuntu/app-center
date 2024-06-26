import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/src/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

void main() {
  group('SnapdException', () {
    final testCases = <({
      String name,
      SnapdException exception,
      String Function(AppLocalizations) expected
    })>[
      (
        name: 'network timeout',
        exception: SnapdException(kind: 'network-timeout', message: 'message'),
        expected: (l10n) => l10n.snapdExceptionNetworkTimeout
      ),
      (
        name: 'too many requests',
        exception: SnapdException(message: 'too many requests'),
        expected: (l10n) => l10n.snapdExceptionTooManyRequests,
      ),
      (
        name: 'running apps',
        exception: SnapdException(
          kind: 'error',
          message:
              'cannot refresh "testsnap": snap "testsnap" has running apps (testapp)',
        ),
        expected: (l10n) => l10n.snapdExceptionRunningApps('testsnap')
      ),
    ];

    for (final testCase in testCases) {
      testWidgets(testCase.name, (tester) async {
        await tester.pumpApp((context) => const Scaffold());
        expect(
          testCase.exception.prettyFormat(tester.l10n),
          testCase.expected(tester.l10n),
        );
      });
    }
  });
}
