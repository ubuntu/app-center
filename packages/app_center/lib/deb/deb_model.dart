import 'dart:async';

import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:appstream/appstream.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'deb_model.freezed.dart';
part 'deb_model.g.dart';

@freezed
class DebData with _$DebData {
  factory DebData({
    required String id,
    required AppstreamComponent component,
    required bool hasUpdate,
    required StreamSubscription<PackageKitServiceError> errorStream,
    PackageKitPackageEvent? packageInfo,
    int? activeTransactionId,
    PackageKitServiceError? error,
  }) = _DebData;

  DebData._();

  bool get isInstalled => packageInfo?.info == PackageKitInfo.installed;
}

@riverpod
class DebModel extends _$DebModel {
  final packageKit = getService<PackageKitService>();

  @override
  Future<DebData> build(String id) async {
    final appstream = getService<AppstreamService>();
    final component = appstream.getFromId(id);

    await packageKit.activateService();

    final packageInfo = await _getPackageInfo(component);
    final hasUpdate = await _getUpdates(packageInfo!);

    final errorListener = packageKit.errorStream.listen(_onError);
    ref.onDispose(errorListener.cancel);

    return DebData(
      id: id,
      component: component,
      packageInfo: packageInfo,
      hasUpdate: hasUpdate,
      errorStream: errorListener,
    );
  }

  Future<void> installDeb() {
    assert(state.valueOrNull?.packageInfo != null);
    return _packageKitAction(
      () => packageKit.install(state.value!.packageInfo!.packageId),
    );
  }

  Future<void> removeDeb() {
    assert(state.valueOrNull?.packageInfo != null);
    return _packageKitAction(
      () => packageKit.remove(state.value!.packageInfo!.packageId),
    );
  }

  Future<void> updateDeb() {
    assert(state.valueOrNull?.packageInfo != null);
    return _packageKitAction(
      () => packageKit.update(state.value!.packageInfo!.packageId),
    );
  }

  Future<void> cancelTransaction() async {
    if (state.value?.activeTransactionId == null) return;
    await packageKit.cancelTransaction(state.value!.activeTransactionId!);
  }

  Future<void> _onError(PackageKitServiceError error) async {
    state = AsyncValue.data(state.value!.copyWith(error: error));
  }

  Future<PackageKitPackageEvent?> _getPackageInfo(
    AppstreamComponent component,
  ) async {
    final packageInfo = await packageKit.resolve(component.package ?? id);
    return packageInfo;
  }

  Future<bool> _getUpdates(PackageKitPackageEvent packageInfo) async {
    final detailsEvent = await packageKit.getUpdates(packageInfo.packageId);
    // a package will list itself in its updates if its up-to-date, so ignore those
    final updates =
        detailsEvent?.updates.where((pid) => pid != packageInfo.packageId);
    var hasUpdate = false;

    for (final packageUpdate in updates ?? <PackageKitPackageId>[]) {
      final package = await packageKit.resolve(packageUpdate.toString());
      hasUpdate = package?.info == PackageKitInfo.installed;
      break;
    }

    return hasUpdate;
  }

  Future<void> _packageKitAction(Future<int> Function() action) async {
    final transactionId = await action.call();
    state = AsyncValue.data(
      state.value!.copyWith(activeTransactionId: transactionId),
    );
    await packageKit.waitTransaction(transactionId);
    ref.invalidateSelf();
  }
}
