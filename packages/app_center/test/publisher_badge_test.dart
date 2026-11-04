import 'package:app_center/apps/app_details_labels.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets('renders nothing without a validation', (tester) async {
    await tester.pumpApp((_) => const PublisherBadge(PublisherValidation.none));

    expect(find.byType(Icon), findsNothing);
    expect(find.byType(Tooltip), findsNothing);
  });

  for (final (validation, icon) in [
    (PublisherValidation.verified, Icons.verified),
    (PublisherValidation.starred, Icons.stars),
  ]) {
    testWidgets('explains the ${validation.name} badge', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp((_) => PublisherBadge(validation));
      final message = validation.localizeTooltip(tester.l10n)!;

      expect(find.byIcon(icon), findsOneWidget);
      expect(find.byTooltip(message), findsOneWidget);
      expect(find.bySemanticsLabel(message), findsOneWidget);
      semantics.dispose();
    });
  }

  testWidgets('shows the tooltip on hover', (tester) async {
    await tester.pumpApp(
      (_) => const PublisherBadge(PublisherValidation.verified),
    );
    final message = tester.l10n.appDetailsVerifiedPublisherTooltip;
    expect(find.text(message), findsNothing);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.verified)));
    await tester.pumpAndSettle();

    expect(find.text(message), findsOneWidget);
  });

  testWidgets('shows the tooltip while focused', (tester) async {
    await tester.pumpApp(
      (_) =>
          const PublisherBadge(PublisherValidation.verified, focusable: true),
    );
    final message = tester.l10n.appDetailsVerifiedPublisherTooltip;

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text(message), findsOneWidget);

    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pumpAndSettle();
    expect(find.text(message), findsNothing);
  });

  for (final large in [true, false]) {
    testWidgets('app title badge takes focus when large is $large', (
      tester,
    ) async {
      await tester.pumpApp(
        (_) => AppTitle(
          title: 'Title',
          publisher: 'Publisher',
          starredPublisher: true,
          large: large,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(
        find.text(tester.l10n.appDetailsStarredPublisherTooltip),
        large ? findsOneWidget : findsNothing,
      );
    });
  }
}
