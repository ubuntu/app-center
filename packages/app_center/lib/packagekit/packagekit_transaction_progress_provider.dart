import 'dart:math' as math;

import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit/packagekit.dart'
    show PackageKitExit, PackageKitFinishedEvent, PackageKitStatus;
import 'package:ubuntu_service/ubuntu_service.dart';

/// Share of the overall progress taken by the download phase when it is
/// followed by an install phase.
const _downloadWeight = 0.5;

/// Provides the progress (0.0 to 1.0) of an active PackageKit transaction.
/// Returns null if no transaction is active or the transaction cannot be found.
///
/// PackageKit reports `Percentage` per phase (e.g. download, then install), so
/// it is restarting from 0 for every phase. The phases are combined here into a
/// single monotonic progress value.
final packageKitTransactionProgressProvider = StateProvider.family<double?, int?>((
  ref,
  transactionId,
) {
  if (transactionId == null) return null;

  final packageKit = getService<PackageKitService>();
  final transaction = packageKit.getTransaction(transactionId);
  if (transaction == null) return null;

  var downloadSeen = false;

  double? computeProgress() {
    final percentage = transaction.percentage;
    // PackageKit returns 101 when percentage is unknown
    if (percentage > 100) return null;
    final fraction = percentage / 100.0;

    switch (transaction.status) {
      case PackageKitStatus.download:
        downloadSeen = true;
        return fraction * _downloadWeight;
      case PackageKitStatus.install:
      case PackageKitStatus.update:
      case PackageKitStatus.remove:
      case PackageKitStatus.commit:
      case PackageKitStatus.cleanup:
      // The backend reports the start of the real work under `running`.
      case PackageKitStatus.running:
        final start = downloadSeen ? _downloadWeight : 0.0;
        return start + fraction * (1.0 - start);
      default:
        return null;
    }
  }

  void update() {
    final progress = computeProgress();
    if (progress == null) return;
    // Never go backwards between phases.
    ref.controller.state = math.max(
      ref.controller.state ?? 0.0,
      progress,
    );
  }

  final eventsSubscription = transaction.events.listen((event) {
    // PackageKit doesn't report a final 100%.
    if (event is PackageKitFinishedEvent &&
        event.exit == PackageKitExit.success) {
      ref.controller.state = 1.0;
    }
  });
  ref.onDispose(eventsSubscription.cancel);

  final subscription = transaction.propertiesChanged.listen((changedProps) {
    // On a Status change the percentage still holds the previous phase's value.
    if (changedProps.contains('Percentage')) update();
    // The last download percentage can stop short of 100 (e.g. 64).
    if (changedProps.contains('Status') &&
        downloadSeen &&
        transaction.status != PackageKitStatus.download) {
      ref.controller.state = math.max(
        ref.controller.state ?? 0.0,
        _downloadWeight,
      );
    }
  });
  ref.onDispose(subscription.cancel);

  return computeProgress();
});
