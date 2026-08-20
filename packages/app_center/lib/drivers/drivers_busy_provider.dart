import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether any driver install/update/uninstall transaction is in progress,
/// across all devices.
///
/// Coarse gate: only one driver operation runs at a time, so the UI can
/// disable other rows off a single flag. Does not guard PackageKit
/// transactions started from other pages.
final driversBusyProvider = StateProvider<bool>((_) => false);
