import 'dart:ui';

import 'package:app_center/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  testWidgets('error dialog text can be selected and copied', (tester) async {
    const title = 'Something went wrong';
    const message = 'An error message users want to copy';

    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardText =
              (call.arguments as Map<String, dynamic>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpApp(
      (context) => ElevatedButton(
        onPressed: () => showErrorDialog(
          context: context,
          title: title,
          message: message,
        ),
        child: const Text('open'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.byType(SelectionArea)),
      findsOneWidget,
    );

    // Drag across the message to select it, then copy it.
    final messageText = find.text(message);
    final gesture = await tester.startGesture(
      tester.getTopLeft(messageText) + const Offset(1, 1),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(
      tester.getBottomRight(messageText) - const Offset(1, 1),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(clipboardText, message);
  });
}
