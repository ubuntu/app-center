import 'dart:math' as math;

import 'package:app_center/packagekit/packagekit.dart';
import 'package:packagekit/packagekit.dart'
    show
        PackageKitEvent,
        PackageKitExit,
        PackageKitFinishedEvent,
        PackageKitStatus;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'packagekit_transaction_progress_provider.g.dart';

/// Share of the overall progress taken by the download phase when it is
/// followed by an install phase.
const _downloadWeight = 0.7;

/// Provides the progress (0.0 to 1.0) of an active PackageKit transaction.
/// Returns null if no transaction is active or the transaction cannot be found.
///
/// PackageKit reports `Percentage` per phase (e.g. download, then install), so
/// it is restarting from 0 for every phase. The phases are combined here into a
/// single monotonic progress value.
@riverpod
class PackageKitTransactionProgress extends _$PackageKitTransactionProgress {
  late PackageKitTransaction _transaction;
  bool _downloadSeen = false;

  @override
  double? build(int? transactionId) {
    // The notifier instance is reused across rebuilds.
    _downloadSeen = false;
    if (transactionId == null) return null;

    final transaction = getService<PackageKitService>().getTransaction(
      transactionId,
    );
    if (transaction == null) return null;
    _transaction = transaction;

    final eventsSubscription = transaction.events.listen(_onEvent);
    ref.onDispose(eventsSubscription.cancel);
    final propertiesSubscription = transaction.propertiesChanged.listen(
      _onPropertiesChanged,
    );
    ref.onDispose(propertiesSubscription.cancel);

    return _computeProgress();
  }

  double? _computeProgress() {
    final percentage = _transaction.percentage;
    // PackageKit returns 101 when percentage is unknown
    if (percentage > 100) return null;
    final fraction = percentage / 100.0;

    switch (_transaction.status) {
      case PackageKitStatus.download:
        _downloadSeen = true;
        return fraction * _downloadWeight;
      case PackageKitStatus.install:
      case PackageKitStatus.update:
      case PackageKitStatus.remove:
      case PackageKitStatus.commit:
      case PackageKitStatus.cleanup:
      // The backend reports the start of the real work under `running`.
      case PackageKitStatus.running:
        final start = _downloadSeen ? _downloadWeight : 0.0;
        return start + fraction * (1.0 - start);
      default:
        return null;
    }
  }

  /// Never goes backwards between phases.
  void _advanceTo(double progress) {
    state = math.max(state ?? 0.0, progress);
  }

  void _onEvent(PackageKitEvent event) {
    // PackageKit doesn't report a final 100%.
    if (event is PackageKitFinishedEvent &&
        event.exit == PackageKitExit.success) {
      state = 1.0;
    }
  }

  void _onPropertiesChanged(List<String> changedProps) {
    // On a Status change the percentage still holds the previous phase's value.
    if (changedProps.contains('Percentage')) {
      final progress = _computeProgress();
      if (progress != null) _advanceTo(progress);
    }
    // The last download percentage can stop short of 100 (e.g. 64).
    if (changedProps.contains('Status') &&
        _downloadSeen &&
        _transaction.status != PackageKitStatus.download) {
      _advanceTo(_downloadWeight);
    }
  }
}
