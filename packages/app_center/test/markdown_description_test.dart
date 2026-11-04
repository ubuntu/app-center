import 'package:app_center/widgets/markdown_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
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
}
