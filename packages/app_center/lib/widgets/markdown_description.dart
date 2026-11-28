import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/widgets/legacy_material_bridge.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_ui/material_ui.dart';

class MarkdownDescription extends StatelessWidget {
  const MarkdownDescription({required this.data, super.key});

  final String data;

  @override
  Widget build(BuildContext context) {
    return LegacyMaterialBridge(
      child: Builder(
        builder: (context) {
          final theme = legacy.Theme.of(context);

          return MarkdownBody(
            selectable: true,
            data: data.escapedMarkdown(),
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              // flutter_markdown shrinks code to 85% of body text by default,
              // and the span background it adds covers the selection highlight.
              code: theme.textTheme.bodyMedium!.copyWith(
                fontFamily: 'monospace',
                backgroundColor: Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }
}
