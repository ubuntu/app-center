import 'dart:async';

import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

/// Provides the progress (0.0 to 1.0) of an active PackageKit transaction.
/// Returns null if no transaction is active or the transaction cannot be found.
final packageKitTransactionProgressProvider =
    StateProvider.family<double?, int?>((ref, transactionId) {
      if (transactionId == null) return null;

      final packageKit = getService<PackageKitService>();
      final transaction = packageKit.getTransaction(transactionId);
      if (transaction == null) return null;

      // Listen to property changes and update progress
      late final StreamSubscription<List<String>> subscription;
      subscription = transaction.propertiesChanged.listen((changedProps) {
        if (changedProps.contains('Percentage')) {
          final percentage = transaction.percentage;
          // PackageKit returns 101 when percentage is unknown
          if (percentage <= 100) {
            ref.controller.state = percentage / 100.0;
          }
        }
      });
      ref.onDispose(subscription.cancel);

      // Return initial progress
      final percentage = transaction.percentage;
      return percentage <= 100 ? percentage / 100.0 : null;
    });
