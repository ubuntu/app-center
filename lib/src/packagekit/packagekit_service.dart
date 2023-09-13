import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

typedef PackageKitPackageInfo = PackageKitPackageEvent;

class PackageKitService {
  PackageKitService({
    @visibleForTesting PackageKitClient? client,
    @visibleForTesting DBusClient? dbus,
  })  : _client = client ?? getService<PackageKitClient>(),
        _dbus = dbus ?? DBusClient.system();
  final PackageKitClient _client;
  final DBusClient _dbus;

  bool get isAvailable => _isAvailable;
  bool _isAvailable = false;

  // Keep track of active transactions.
  // TODO: Implement `GetTransactionList` in packagekit.dart instead.
  int _nextId = 0;
  final Map<int, PackageKitTransaction> _transactions = {};

  // To be used to access the transaction properties (e.g. progress) of transactions
  // that run in the background for longer (e.g. installing a package).
  // The respective methods will return a transaction ID, similar to how methods
  // in the snap client return change IDs.
  PackageKitTransaction? getTransaction(int id) => _transactions[id];

  /// Explicitly activates the PackageKit service in case it is not running.
  /// Prevents AppArmor denials when trying to call a well-known method while
  /// the daemon is inactive.
  /// See https://github.com/ubuntu/app-center/issues/1215
  /// and https://forum.snapcraft.io/t/apparmor-denial-in-new-snap-store-despite-connected-packagekit-control-interface/35290
  Future<void> activateService() async {
    if (_isAvailable) return;

    final object = DBusRemoteObject(
      _dbus,
      name: 'org.freedesktop.DBus',
      path: DBusObjectPath('/org/freedesktop/DBus'),
    );
    await object.callMethod(
      'org.freedesktop.DBus',
      'StartServiceByName',
      const [DBusString('org.freedesktop.PackageKit'), DBusUint32(0)],
    );
    try {
      await _client.connect();
      _isAvailable = true;
    } on DBusServiceUnknownException catch (_) {
      // Service isn't available
    }
  }

  /// Creates a new `PackageKitTransaction` and invokes `action` on it, if
  /// provided. If a `listener` is provided it will receive the `PackageKitEvent`s
  /// from the transaction.
  /// Returns an internal transaction id.
  Future<int> _createTransaction({
    Future<void> Function(PackageKitTransaction transaction)? action,
    void Function(PackageKitEvent event)? listener,
  }) async {
    final transaction = await _client.createTransaction();
    final id = _nextId++;
    _transactions[id] = transaction;

    late final StreamSubscription subscription;
    subscription = transaction.events.listen((event) {
      listener?.call(event);
      if (event is PackageKitFinishedEvent || event is PackageKitDestroyEvent) {
        _transactions.remove(id);
        subscription.cancel();
      }
    });
    await action?.call(transaction);
    return id;
  }

  /// Waits until the transaction specified by the internal `id` has finished.
  Future<void> waitTransaction(int id) async {
    if (!_transactions.keys.contains(id)) return;

    final completer = Completer();
    final subscription = _transactions[id]!.events.listen(
      (event) {
        if (event is PackageKitFinishedEvent ||
            event is PackageKitDestroyEvent) {
          completer.complete();
        }
      },
      onDone: completer.complete,
    );
    await completer.future;
    await subscription.cancel();
  }

  /// Creates a transaction that installs the package given by `packageId` and
  /// returns the transaction ID.
  Future<int> install(PackageKitPackageId packageId) async =>
      _createTransaction(
        action: (transaction) => transaction.installPackages([packageId]),
      );

  /// Creates a transaction that removes the package given by `packageId` and
  /// returns the transaction ID.
  // TODO: Decide how to handle dependencies. Autoremove? Ask the user?
  Future<int> remove(PackageKitPackageId packageId) async => _createTransaction(
        action: (transaction) => transaction.removePackages([packageId]),
      );

  /// Resolves a single package name provided by `name`.
  Future<PackageKitPackageInfo?> resolve(String name) async {
    PackageKitPackageInfo? info;
    await _createTransaction(
      action: (transaction) => transaction.resolve([name]),
      listener: (event) {
        if (event is PackageKitPackageEvent) {
          info = event;
        }
      },
    ).then(waitTransaction);
    return info;
  }

  Future<void> dispose() async {
    await _dbus.close();
    await _client.close();
  }
}
