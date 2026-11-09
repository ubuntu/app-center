import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'uninstall_check_provider.g.dart';

/// Whether an uninstall is being checked for dependents (simulated and
/// confirmed by the user). Uninstall buttons are disabled meanwhile, and only
/// one check runs at a time.
@Riverpod(keepAlive: true)
class UninstallCheck extends _$UninstallCheck {
  @override
  bool build() => false;

  /// Marks a check as started. Returns false if one is already running.
  bool begin() {
    if (state) return false;
    state = true;
    return true;
  }

  void end() {
    if (ref.mounted) state = false;
  }
}
