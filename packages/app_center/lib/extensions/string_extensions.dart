extension StringExtension on String {
  String escapedMarkdown() {
    // This covers both links and images
    final linkPattern = RegExp(
      r'\[.*?\]\(.*?\)',
      multiLine: true,
      dotAll: true,
    );
    final escaped = replaceAllMapped(
      linkPattern,
      (match) => '\\${match.group(0)}',
    );

    return escaped;
  }
}
