String normalizeCommonId(String? value) => value?.trim().toLowerCase() ?? '';

String normalizeDesktopId(String? value, {String? snapName}) {
  var normalized = normalizeCommonId(value);
  // snapd reports desktop files as absolute paths.
  normalized = normalized.substring(normalized.lastIndexOf('/') + 1);
  if (normalized.endsWith('.desktop')) {
    normalized = normalized.substring(0, normalized.length - '.desktop'.length);
  }

  final normalizedSnapName = normalizeCommonId(snapName);
  final prefix = '${normalizedSnapName}_';
  if (normalizedSnapName.isNotEmpty && normalized.startsWith(prefix)) {
    normalized = normalized.substring(prefix.length);
  }

  return normalized;
}
