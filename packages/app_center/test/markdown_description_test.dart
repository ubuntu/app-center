import 'package:app_center/l10n.dart';
import 'package:app_center/widgets/markdown_description.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  testWidgets('renders code at body size without a span background', (
    tester,
  ) async {
    await tester.pumpApp((_) => const MarkdownDescription(data: '`code`'));

    final code = tester
        .widget<MarkdownBody>(find.byType(MarkdownBody))
        .styleSheet!
        .code!;
    final body = Theme.of(tester.context).textTheme.bodyMedium!;

    expect(code.fontSize, body.fontSize);
    expect(code.backgroundColor, Colors.transparent);
  });

  testWidgets('markdown follows the dark theme and selection color', (
    tester,
  ) async {
    const bodyColor = Color(0xffeeeeee);
    const selectionColor = Color(0xff663399);
    const cursorColor = Color(0xff99ccff);
    final theme = ThemeData.dark().copyWith(
      textTheme: ThemeData.dark().textTheme.copyWith(
        bodyMedium: const TextStyle(color: bodyColor, fontSize: 18),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: selectionColor,
        cursorColor: cursorColor,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: localizationsDelegates,
        home: const Scaffold(body: MarkdownDescription(data: 'Description')),
      ),
    );

    final text = tester.widget<legacy.SelectableText>(
      find.byType(legacy.SelectableText),
    );
    expect(text.textSpan!.style!.color, bodyColor);
    expect(text.textSpan!.style!.fontSize, 18);
    final editable = tester.widget<legacy.EditableText>(
      find.byType(legacy.EditableText),
    );
    expect(editable.selectionColor, selectionColor);
    expect(editable.cursorColor, cursorColor);
  });
}
