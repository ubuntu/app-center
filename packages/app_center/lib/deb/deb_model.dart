import 'dart:async';

import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/manage/deb_updates_provider.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:appstream/appstream.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'deb_model.freezed.dart';
part 'deb_model.g.dart';

@freezed
class DebData extends AppMetadata with _$DebData {
  factory DebData({
    required String id,
    required AppstreamComponent component,
    required bool hasUpdate,
    required StreamSubscription<PackageKitServiceError> errorStream,
    PackageKitPackageEvent? packageInfo,
    PackageKitPackageId? updatePackageId,
    int? activeTransactionId,
    PackageKitServiceError? error,
  }) = _DebData;

  DebData._();

  bool get isInstalled => packageInfo?.info == PackageKitInfo.installed;

  @override
  AppConfinement? get confinement => AppConfinement.fromDeb();

  @override
  String? get publisher => component.getLocalizedDeveloperName();

  @override
  int? get downloadSize => null;

  @override
  String? get license => component.projectLicense;

  @override
  Map<AppLink, String>? get links => Map.fromEntries(
        component.urls
            .where(
              (url) => [
                AppstreamUrlType.contact,
                AppstreamUrlType.homepage,
              ].contains(url.type),
            )
            .map((url) => MapEntry(AppLink.fromAppstream(url.type), url.url)),
      );

  @override
  DateTime? get published => null;

  @override
  String? get version => packageInfo?.packageId.version ?? '';
}

@Riverpod(keepAlive: true)
class DebModel extends _$DebModel {
  final packageKit = getService<PackageKitService>();

  @override
  Future<DebData> build(String id) async {
    final appstream = getService<AppstreamService>();
    final component = appstream.getFromId(id);

    await packageKit.activateService();

    final packageInfo = await _getPackageInfo(component);
    final updateInfo = await _getUpdates(packageInfo!);

    final errorListener = packageKit.errorStream.listen(_onError);
    ref.onDispose(errorListener.cancel);

    return DebData(
      id: id,
      component: component,
      packageInfo: packageInfo,
      hasUpdate: updateInfo.hasUpdate,
      updatePackageId: updateInfo.updatePackageId,
      errorStream: errorListener,
    );
  }

  Future<void> installDeb() async {
    final packageId = state.valueOrNull?.packageInfo?.packageId;
    if (packageId == null) return;
    final success = await _packageKitAction(
      () => packageKit.install(packageId),
    );
    if (success) {
      // Invalidate to refresh the package info (isInstalled state changed)
      ref.invalidateSelf();
    }
  }

  Future<void> removeDeb() async {
    final packageId = state.valueOrNull?.packageInfo?.packageId;
    if (packageId == null) return;
    final success = await _packageKitAction(
      () => packageKit.remove(packageId),
    );
    if (success) {
      ref.read(installedDebsProvider.notifier).removeFromList(id);
      ref.read(debUpdatesProvider.notifier).removeFromList(id);
    }
  }

  Future<void> updateDeb(PackageKitPackageId updatePackageId) async {
    final success = await _packageKitAction(
      () => packageKit.update(updatePackageId),
    );
    if (success) {
      ref.read(debUpdatesProvider.notifier).removeFromList(id);
    }
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
    final name = component.package ?? id;
    final results = await packageKit.resolve([name]);
    return results[name];
  }

  Future<({bool hasUpdate, PackageKitPackageId? updatePackageId})> _getUpdates(
    PackageKitPackageEvent packageInfo,
  ) async {
    final detailsEvent = await packageKit.getUpdates(packageInfo.packageId);
    // a package will list itself in its updates if its up-to-date, so ignore those
    final updates =
        detailsEvent?.updates.where((pid) => pid != packageInfo.packageId);

    for (final packageUpdate in updates ?? <PackageKitPackageId>[]) {
      final updateName = packageUpdate.toString();
      final resolved = await packageKit.resolve([updateName]);
      if (resolved[updateName]?.info == PackageKitInfo.installed) {
        return (hasUpdate: true, updatePackageId: packageUpdate);
      }
      break;
    }

    return (hasUpdate: false, updatePackageId: null);
  }

  Future<bool> _packageKitAction(Future<int> Function() action) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;

    try {
      final transactionId = await action.call();
      state = AsyncValue.data(
        currentState.copyWith(activeTransactionId: transactionId),
      );
      await packageKit.waitTransaction(transactionId);
      // Clear the active transaction ID
      state = AsyncValue.data(
        state.value!.copyWith(activeTransactionId: null),
      );
      return true;
    } on Exception {
      // Clear any active transaction on failure
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.copyWith(activeTransactionId: null),
        );
      }
      return false;
    }
  }
}
