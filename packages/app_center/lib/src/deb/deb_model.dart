import 'dart:async';

import 'package:app_center/appstream.dart';
import 'package:app_center/packagekit.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final debModelProvider =
    ChangeNotifierProvider.family.autoDispose<DebModel, String>(
  (ref, id) => DebModel(
    appstream: getService<AppstreamService>(),
    packageKit: getService<PackageKitService>(),
    id: id,
  )..init(),
);

final transactionProvider =
    StreamProvider.family.autoDispose<PackageKitTransaction, int>((ref, id) {
  final transaction = getService<PackageKitService>().getTransaction(id);
  if (transaction == null) return const Stream.empty();

  return transaction.propertiesChanged.asyncMap((_) => transaction);
});

class DebModel extends ChangeNotifier {
  DebModel({
    required this.appstream,
    required this.packageKit,
    required this.id,
  })  : _state = const AsyncValue.loading(),
        component = appstream.getFromId(id),
        assert(appstream.initialized, 'appstream has not been initialized');

  final AppstreamService appstream;
  final PackageKitService packageKit;
  final String id;
  final AppstreamComponent component;

  int? get activeTransactionId => _activeTransactionId;
  int? _activeTransactionId;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  PackageKitPackageInfo? packageInfo;
  bool get isInstalled => packageInfo?.info == PackageKitInfo.installed;

  Stream<PackageKitServiceError> get errorStream => packageKit.errorStream;

  Future<void> init() async {
    _state = await AsyncValue.guard(() async {
      await packageKit.activateService();
      await _getPackageInfo();

      notifyListeners();
    });
  }

  Future<void> _getPackageInfo() async {
    packageInfo = await packageKit.resolve(component.package ?? id);
  }

  Future<void> _packageKitAction(Future<int> Function() action) async {
    final transactionId = await action.call();
    _activeTransactionId = transactionId;
    notifyListeners();
    await packageKit.waitTransaction(transactionId);
    await _getPackageInfo();
    _activeTransactionId = null;
    notifyListeners();
  }

  Future<void> install() {
    assert(packageInfo != null);
    return _packageKitAction(() => packageKit.install(packageInfo!.packageId));
  }

  Future<void> remove() {
    assert(packageInfo != null);
    return _packageKitAction(() => packageKit.remove(packageInfo!.packageId));
  }

  Future<void> cancel() async {
    if (activeTransactionId == null) return;
    await packageKit.cancelTransaction(activeTransactionId!);
  }
}
