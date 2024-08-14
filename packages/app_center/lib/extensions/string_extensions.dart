import 'package:flutter/widgets.dart';

extension StringExtension on String {
  String escapedMarkdown() {
    final imagePattern = RegExp(r'!\[.*?\]\(.*?\)');
    final linkPattern = RegExp(r'\[.*?\]\(.*?\)');

    // Replace images with escaped versions
    final escaped = replaceAllMapped(
      imagePattern,
      (match) => '\\${match.group(0)}',
    ).replaceAllMapped(
      linkPattern,
      (match) => '\\${match.group(0)}',
    );

    return escaped;
  }
}
