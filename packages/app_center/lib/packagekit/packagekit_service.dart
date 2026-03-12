import 'dart:async';
import 'dart:io';

import 'package:app_center/packagekit/logger.dart';
import 'package:dbus/dbus.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

export 'package:packagekit/packagekit.dart' show PackageKitTransaction;

typedef PackageKitPackageInfo = PackageKitPackageEvent;
typedef PackageKitServiceError = PackageKitErrorCodeEvent;
typedef PackageKitPackageDetails = PackageKitDetailsEvent;

class PackageKitTransactionError implements Exception {
  PackageKitTransactionError(this.message);
  final String message;

  @override
  String toString() => 'PackageKitTransactionError: $message';
}

class PackageKitService {
  PackageKitService({
    @visibleForTesting PackageKitClient? client,
    @visibleForTesting DBusClient? dbus,
    @visibleForTesting FileSystem? fs,
  })  : _client = client ?? getService<PackageKitClient>(),
        _dbus = dbus ?? DBusClient.system(),
        _fs = fs ?? const LocalFileSystem();

  final PackageKitClient _client;
  final DBusClient _dbus;
  final FileSystem _fs;

  bool get isAvailable => _isAvailable;
  bool _isAvailable = false;

  Stream<PackageKitServiceError> get errorStream =>
      _errorStreamController.stream;
  final StreamController<PackageKitServiceError> _errorStreamController =
      StreamController.broadcast();

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
      log.info(
        'Could not connect to PackageKit - marking service as unavailable',
      );
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

    late final StreamSubscription<PackageKitEvent> subscription;
    subscription = transaction.events.listen((event) {
      listener?.call(event);
      if (event is PackageKitFinishedEvent || event is PackageKitDestroyEvent) {
        _transactions.remove(id);
        subscription.cancel();
      } else if (event is PackageKitErrorCodeEvent) {
        _errorStreamController.add(event);
        log.error(
          'Received PackageKitErrorCodeEvent (${event.code}): ${event.details}',
        );
      }
    });
    await action?.call(transaction);
    return id;
  }

  /// Waits until the transaction specified by the internal `id` has finished.
  /// Throws a [PackageKitTransactionError] if the transaction fails or is
  /// destroyed before finishing.
  Future<void> waitTransaction(int id) async {
    if (!_transactions.keys.contains(id)) {
      throw PackageKitTransactionError('Transaction $id not found');
    }

    final completer = Completer();
    final subscription = _transactions[id]!.events.listen(
      (event) {
        if (event is PackageKitFinishedEvent) {
          if (event.exit == PackageKitExit.success) {
          completer.complete();
          } else {
            completer.completeError(
              PackageKitTransactionError(
                'Transaction $id finished with exit code: ${event.exit}',
              ),
            );
          }
        } else if (event is PackageKitDestroyEvent) {
          completer.completeError(
            PackageKitTransactionError('Transaction $id was destroyed'),
          );
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            PackageKitTransactionError(
              'Transaction $id stream closed unexpectedly',
            ),
          );
        }
      },
    );
    await completer.future.whenComplete(subscription.cancel);
  }

  Future<void> cancelTransaction(int id) async {
    if (!_transactions.keys.contains(id)) return;
    return _transactions[id]!.cancel();
  }

  /// Creates a transaction that installs the package given by `packageId` and
  /// returns the transaction ID.
  Future<int> install(PackageKitPackageId packageId) async =>
      _createTransaction(
        action: (transaction) => transaction.installPackages([packageId]),
      );

  /// Creates a transaction that installs all of the given packages by
  /// `packageId` and returns the transaction ID.
  Future<int> installAll(Iterable<PackageKitPackageId> packageId) async =>
      _createTransaction(
        action: (transaction) => transaction.installPackages(packageId),
      );

  /// Creates a transaction that installs the local package given by `path` and
  /// returns the transaction ID.
  Future<int> installLocal(String path) async => _createTransaction(
        action: (transaction) =>
            transaction.installFiles([_getAbsolutePath(path)]),
      );

  /// Get the packages that provide the given id (usually a codec string).
  Future<Iterable<PackageKitPackageInfo>> whatProvides(String id) async {
    final info = <PackageKitPackageInfo>[];
    await _createTransaction(
      action: (transaction) => transaction.whatProvides([id]),
      listener: (event) {
        if (event is PackageKitPackageEvent) {
          info.add(event);
        }
      },
    ).then(waitTransaction);
    return info;
  }

  /// Creates a transaction that removes the package given by `packageId` and
  /// returns the transaction ID.
  // TODO: Decide how to handle dependencies. Autoremove? Ask the user?
  Future<int> remove(PackageKitPackageId packageId) async => _createTransaction(
        action: (transaction) => transaction.removePackages([packageId]),
      );

  Future<int> update(PackageKitPackageId packageId) async => _createTransaction(
        action: (transaction) => transaction.updatePackages([packageId]),
      );

  static Future<String> _getNativeArchitecture() async {
    final snapArch = Platform.environment['SNAP_ARCH'];
    if (snapArch != null) {
      return snapArch;
    }

    final result = await Process.run('/usr/bin/dpkg', ['--print-architecture']);
    return (result.stdout as String).trim();
  }

  String _getAbsolutePath(String path) => _fs.file(path).absolute.path;

  /// Resolves package names in a single transaction.
  /// Returns a map of package name to package info.
  /// If [installedOnly] is true, only installed packages are returned.
  Future<Map<String, PackageKitPackageInfo?>> resolve(
    List<String> names, {
    bool installedOnly = false,
    @visibleForTesting String? architecture,
  }) async {
    if (names.isEmpty) return {};

    final possibleArchs = [
      architecture ?? await _getNativeArchitecture(),
      'all',
    ];
    final results = {
      for (final name in names) name: null as PackageKitPackageInfo?,
    };

    await _createTransaction(
      action: (transaction) => transaction.resolve(names),
      listener: (event) {
        if (event is PackageKitPackageEvent &&
            possibleArchs.contains(event.packageId.arch) &&
            (!installedOnly || event.info == PackageKitInfo.installed)) {
          results[event.packageId.name] = event;
        }
      },
    ).then(waitTransaction);

    for (final entry in results.entries) {
      if (entry.value == null) {
        log.error('Couldn\'t resolve package ${entry.key}');
    }
    }

    return results;
  }

  Future<PackageKitUpdateDetailEvent?> getUpdates(
    PackageKitPackageId packageId,
  ) async {
    PackageKitUpdateDetailEvent? details;
    await _createTransaction(
      action: (transaction) => transaction.getUpdateDetail([packageId]),
      listener: (event) {
        if (event is PackageKitUpdateDetailEvent) {
          details = event;
        }
      },
    ).then(waitTransaction);
    if (details == null) {
      log.error('Couldn\'t get update details for package $packageId');
    }
    return details;
  }

  /// Returns all packages that have updates available.
  Future<List<PackageKitPackageInfo>> getAllAvailableUpdates() async {
    final updates = <PackageKitPackageInfo>[];
    await _createTransaction(
      action: (transaction) => transaction.getUpdates(),
      listener: (event) {
        if (event is PackageKitPackageEvent) {
          updates.add(event);
        }
      },
    ).then(waitTransaction);
    return updates;
  }

  Future<PackageKitPackageDetails?> getDetailsLocal(String path) async {
    PackageKitPackageDetails? details;
    final absolutePath = _getAbsolutePath(path);
    await _createTransaction(
      action: (transaction) => transaction.getDetailsLocal([absolutePath]),
      listener: (event) {
        if (event is PackageKitDetailsEvent) {
          details = event;
        }
      },
    ).then(waitTransaction);
    if (details == null) {
      log.error('Couldn\'t get details for local package $absolutePath');
    }
    return details;
  }

  /// Returns details for multiple packages in a single transaction.
  /// Returns a map of package name to details.
  Future<Map<String, PackageKitPackageDetails>> getDetailsMany(
    List<PackageKitPackageId> packageIds,
  ) async {
    if (packageIds.isEmpty) return {};

    final results = <String, PackageKitPackageDetails>{};
    await _createTransaction(
      action: (transaction) => transaction.getDetails(packageIds),
      listener: (event) {
        if (event is PackageKitDetailsEvent) {
          results[event.packageId.name] = event;
        }
      },
    ).then(waitTransaction);
    return results;
  }

  /// Returns all installed packages on the system.
  Future<List<PackageKitPackageInfo>> getInstalledPackages() async {
    final packages = <PackageKitPackageInfo>[];
    await _createTransaction(
      action: (transaction) => transaction.getPackages(
        filter: {PackageKitFilter.installed},
      ),
      listener: (event) {
        if (event is PackageKitPackageEvent) {
          packages.add(event);
        }
      },
    ).then(waitTransaction);
    return packages;
  }

  Future<void> dispose() async {
    await _dbus.close();
    await _client.close();
    await _errorStreamController.close();
  }
}
