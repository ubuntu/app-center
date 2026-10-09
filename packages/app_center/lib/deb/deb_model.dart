import 'dart:async';

import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'deb_model.freezed.dart';
part 'deb_model.g.dart';

enum DebTransactionKind { install, update, remove }

@freezed
abstract class DebData extends AppMetadata with _$DebData {
  factory DebData({
    required String id,
    required AppstreamComponent component,
    required bool hasUpdate,
    required StreamSubscription<PackageKitServiceError> errorStream,
    PackageKitPackageEvent? packageInfo,
    PackageKitDetailsEvent? details,
    int? activeTransactionId,
    DebTransactionKind? activeTransactionKind,
    PackageKitPackageId? updatePackageId,
    PackageKitServiceError? error,
  }) = _DebData;

  DebData._();

  bool get isInstalled => packageInfo?.info == PackageKitInfo.installed;

  /// Returns true if this package is compulsory for any of the given [desktops].
  bool isCompulsoryFor(List<String> desktops) =>
      component.isCompulsoryFor(desktops);

  @override
  AppConfinement? get confinement => AppConfinement.fromDeb();

  @override
  String? get publisher => component.getLocalizedDeveloperName();

  @override
  int? get downloadSize => details?.size;

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
  DateTime? get published =>
      component.releases.map((r) => r.date).whereType<DateTime>().maxOrNull;

  @override
  String? get version => packageInfo?.packageId.version;
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
    final updatePackageId = await _getUpdate(packageInfo!);
    final details = (await packageKit.getDetails([
      packageInfo.packageId,
    ]))[packageInfo.packageId.name];

    final errorListener = packageKit.errorStream.listen(_onError);
    ref.onDispose(errorListener.cancel);

    return DebData(
      id: id,
      component: component,
      packageInfo: packageInfo,
      details: details,
      hasUpdate: updatePackageId != null,
      updatePackageId: updatePackageId,
      errorStream: errorListener,
    );
  }

  Future<PackageKitMutationOutcome> installDeb() {
    assert(state.value?.packageInfo != null);
    return _packageKitAction(
      DebTransactionKind.install,
      () => packageKit.install(state.value!.packageInfo!.packageId),
    );
  }

  Future<PackageKitMutationOutcome> removeDeb() {
    assert(state.value?.packageInfo != null);
    return _packageKitAction(
      DebTransactionKind.remove,
      () => packageKit.remove(state.value!.packageInfo!.packageId),
    );
  }

  /// Updates to [updateId], or submits the installed package ID if omitted.
  Future<PackageKitMutationOutcome> updateDeb({
    PackageKitPackageId? updateId,
  }) {
    assert(state.value?.packageInfo != null);
    return _packageKitAction(
      DebTransactionKind.update,
      () => packageKit.update(
        updateId ?? state.value!.packageInfo!.packageId,
      ),
    );
  }

  Future<void> cancelTransaction() async {
    if (state.value?.activeTransactionId == null) return;
    await packageKit.cancelTransaction(state.value!.activeTransactionId!);
    state = AsyncValue.data(
      state.value!.copyWith(
        activeTransactionId: null,
        activeTransactionKind: null,
      ),
    );
  }

  Future<void> _onError(PackageKitServiceError error) async {
    state = AsyncValue.data(
      state.value!.copyWith(
        error: error,
        activeTransactionId: null,
        activeTransactionKind: null,
      ),
    );
  }

  Future<PackageKitPackageEvent?> _getPackageInfo(
    AppstreamComponent component,
  ) async {
    final packageName = component.package ?? id;
    final results = await packageKit.resolve([packageName]);
    return results[packageName];
  }

  Future<PackageKitPackageId?> _getUpdate(
    PackageKitPackageEvent packageInfo,
  ) async {
    final detailsEvent = await packageKit.getUpdateDetails(
      packageInfo.packageId,
    );
    // a package will list itself in its updates if its up-to-date, so ignore those
    final updates = detailsEvent?.updates.where(
      (pid) => pid != packageInfo.packageId,
    );
    if (updates == null || updates.isEmpty) return null;

    /* getUpdateDetails doesn't flag blocked (e.g. phased) updates, so
       cross-check against the installable updates from GetUpdates. */
    final installableNames = (await packageKit.getUpdates())
        .map((u) => u.packageId.name)
        .toSet();

    for (final packageUpdate in updates) {
      final packageName = packageUpdate.name;
      if (!installableNames.contains(packageName)) continue;
      final results = await packageKit.resolve([
        packageName,
      ], installedOnly: true);
      return results[packageName]?.info == PackageKitInfo.installed
          ? packageUpdate
          : null;
    }

    return null;
  }

  Future<PackageKitMutationOutcome> _packageKitAction(
    DebTransactionKind kind,
    Future<int> Function() action,
  ) async {
    final transactionId = await action.call();
    state = AsyncValue.data(
      state.value!.copyWith(
        activeTransactionId: transactionId,
        activeTransactionKind: kind,
      ),
    );
    var outcome = PackageKitMutationOutcome.failed;
    try {
      await packageKit.waitTransaction(transactionId);
      outcome = PackageKitMutationOutcome.success;
    } on PackageKitTransactionCancelled {
      // User cancelled (e.g. dismissed the polkit dialog) — not an error.
      outcome = PackageKitMutationOutcome.cancelled;
      _clearActiveTransaction();
    } on Exception catch (e) {
      /* Report via the same path as PackageKitServiceError events so the
         page shows the error and clears the stuck transaction state. */
      await _onError(
        PackageKitServiceError(
          code: PackageKitError.internalError,
          details: e.toString(),
        ),
      );
    }
    /* On success keep activeTransactionId set until the rebuild finishes, so
       the page doesn't flash the stale install/uninstall state meanwhile. */
    ref.invalidateSelf();
    return outcome;
  }

  void _clearActiveTransaction() {
    state = AsyncValue.data(
      state.value!.copyWith(
        activeTransactionId: null,
        activeTransactionKind: null,
      ),
    );
  }
}
