import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/widgets/legacy_material_bridge.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_ui/material_ui.dart';

/// A Markdown text description.
///
/// Set [selectable] to false when the description is shown inside a
/// [SelectionArea]: selectable paragraphs form their own selection areas and
/// do not join the surrounding selection.
class MarkdownDescription extends StatelessWidget {
  const MarkdownDescription({
    required this.data,
    this.selectable = true,
    super.key,
  });

  final String data;

  /// Whether to create individual selectable texts for the content.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return LegacyMaterialBridge(
      child: Builder(
        builder: (context) {
          final theme = legacy.Theme.of(context);

          return MarkdownBody(
            selectable: selectable,
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
