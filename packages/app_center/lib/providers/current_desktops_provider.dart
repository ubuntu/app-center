import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_desktops_provider.g.dart';

/// Returns the list of active desktop environments from the
/// `XDG_CURRENT_DESKTOP` environment variable (colon-separated).
@riverpod
List<String> currentDesktops(CurrentDesktopsRef ref) {
  final value = Platform.environment['XDG_CURRENT_DESKTOP'] ?? '';
  return value.isEmpty ? [] : value.split(':');
}
