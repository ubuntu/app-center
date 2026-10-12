import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  Future<MouseCursor?> hoverCursor(WidgetTester tester) async {
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(HyperlinkText)));
    await tester.pump();
    return RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1);
  }

  testWidgets('shows a pointer cursor on hover', (tester) async {
    await tester.pumpApp(
      (_) => HyperlinkText(text: 'link', onTap: () {}),
    );

    expect(await hoverCursor(tester), SystemMouseCursors.click);
  });

  testWidgets('shows a pointer cursor on hover inside a SelectionArea', (
    tester,
  ) async {
    await tester.pumpApp(
      (_) => SelectionArea(
        child: HyperlinkText(text: 'link', onTap: () {}),
      ),
    );

    expect(await hoverCursor(tester), SystemMouseCursors.click);
  });
}
