import 'package:app_center/error/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

import '../test_utils.dart';

void main() {
  group('Error view', () {
    group('ActionableErrorActions', () {
      group('retry action button', () {
        testWidgets('is shown if action is present', (tester) async {
          final exception = ErrorMessage.fromObject(
            SnapdException(message: 'persistent network error', kind: 'error'),
          );
          final view = ActionableErrorActions(
              actions: exception.actions,
              label: exception.actionLabel(tester.l10n));

          await tester.pumpWidget(view);

          expect(find.byKey(Key('error-action-retry')), findsOneWidget);
        });

        testWidgets('calls provided onRetry', (tester) async {
          var clicked = false;
          void retry() {
            clicked = true;
          }

          final exception = ErrorMessage.fromObject(
            SnapdException(message: 'persistent network error', kind: 'error'),
          );
          final view = ActionableErrorActions(
            actions: exception.actions,
            label: exception.actionLabel(tester.l10n),
            onRetry: retry,
          );

          await tester.pumpWidget(view);
          expect(find.byKey(Key('error-action-retry')), findsOneWidget);

          await tester.press(find.byKey(Key('error-action-retry')));
          expect(clicked, isTrue);
        });
      });

      group('status action button', () {
        testWidgets('is shown if action is present', (tester) async {
          final exception = ErrorMessage.fromObject(
            SnapdException(message: 'too many requests', kind: 'error'),
          );
          final view = ActionableErrorActions(
              actions: exception.actions,
              label: exception.actionLabel(tester.l10n));
          await tester.pumpWidget(view);

          expect(find.byKey(Key('error-action-check-status')), findsOneWidget);
        });

        testWidgets('opens the status page url', (tester) async {
          var clicked = '';
          Future<bool> checkStatus(String url) {
            clicked = url;
            return Future.value(true);
          }

          // Because this functionality is normally handled via url_launcher
          final exception = ErrorMessage.fromObject(
            SnapdException(message: 'too many requests', kind: 'error'),
          );
          final view = ActionableErrorActions(
            actions: exception.actions,
            label: exception.actionLabel(tester.l10n),
            onCheckStatus: checkStatus,
          );
          await tester.pumpWidget(view);

          await tester.press(find.byKey(Key('error-action-check-status')));

          expect(clicked, 'https://status.snapcraft.io/');
        });
      });
    });
    testWidgets('displays correctly on unactionable error', (tester) async {
      final exception = SnapdException(
        message:
            'cannot refresh "testsnap": snap "testsnap" has running apps (testsnap)',
        kind: 'error',
      );
      final view = ErrorView(error: exception);

      await tester.pumpWidget(view);

      expect(find.byKey(Key('error-asset')), findsOneWidget);
      expect(find.byKey(Key('error-title')), findsOneWidget);
      expect(find.byKey(Key('error-action-body')), findsOneWidget);
      expect(find.byKey(Key('actionable-error-actions')), findsNothing);
    });

    testWidgets('displays actions', (tester) async {
      final exception = ConsolidatedSnapdException(
        {
          'testsnap': SnapdException(
            message:
                'cannot refresh "testsnap": snap "testsnap" has running apps (testsnap)',
            kind: 'error',
          )
        },
        message: 'errors',
      );
      final view = ErrorView(error: exception);

      await tester.pumpWidget(view);

      expect(find.byKey(Key('error-asset')), findsOneWidget);
      expect(find.byKey(Key('error-title')), findsOneWidget);
      expect(find.byKey(Key('error-action-body')), findsOneWidget);
      expect(find.byKey(Key('actionable-error-actions')), findsOneWidget);
    });
  });
}
