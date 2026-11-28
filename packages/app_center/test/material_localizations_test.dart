import 'package:app_center/l10n.dart';
import 'package:app_center/widgets/markdown_description.dart';
import 'package:flutter/gestures.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

void main() {
  tearDown(resetAllServices);

  for (final (locale, copyLabel) in [
    (const Locale('en'), 'Copy'),
    (const Locale('fr'), 'Copier'),
    (const Locale('dz'), 'Copy'),
  ]) {
    testWidgets(
      'markdown selection menu uses $locale Material labels',
      (tester) async {
        String? copied;
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied =
                  (call.arguments as Map<dynamic, dynamic>)['text'] as String?;
            }
            return null;
          },
        );
        addTearDown(
          () => messenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            supportedLocales: supportedLocales,
            localizationsDelegates: localizationsDelegates,
            home: const Scaffold(
              body: MarkdownDescription(data: '**Copy me**'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final selectable = find.byType(legacy.SelectableText);
        expect(selectable, findsOneWidget);

        await tester.tap(selectable);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();

        final gesture = await tester.startGesture(
          tester.getCenter(selectable),
          kind: PointerDeviceKind.mouse,
          buttons: kSecondaryMouseButton,
        );
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        expect(find.text(copyLabel), findsOneWidget);
        await tester.tap(find.text(copyLabel));
        await tester.pump();

        expect(copied, 'Copy me');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
