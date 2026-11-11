import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_model.freezed.dart';
part 'local_deb_model.g.dart';

@freezed
abstract class LocalDebData extends AppMetadata with _$LocalDebData {
  factory LocalDebData({
    required String path,
    required PackageKitDetailsEvent details,
    PackageKitPackageInfo? packageInfo,
    int? activeTransactionId,
    DebTransactionKind? activeTransactionKind,
  }) = _LocalDebData;

  LocalDebData._();

  PackageKitPackageId? get installedPackageId =>
      packageInfo?.info == PackageKitInfo.installed
      ? packageInfo?.packageId
      : null;

  String? get installedVersion => installedPackageId?.version;

  bool get isInstalled => installedVersion == details.packageId.version;

  @override
  AppConfinement? get confinement => AppConfinement.fromDeb();

  @override
  String? get publisher => details.packageId.name;

  @override
  int? get downloadSize => details.size;

  @override
  String? get license => details.license;

  @override
  Map<AppLink, String>? get links => {
    AppLink.homepage: details.url,
  };

  @override
  DateTime? get published => null;

  @override
  String? get version => details.packageId.version;
}

@Riverpod(keepAlive: true)
class LocalDebModel extends _$LocalDebModel {
  // Set before the first await so a double click can't start two transactions.
  bool _busy = false;

  @override
  Future<LocalDebData> build({required String path}) async {
    final packageKit = getService<PackageKitService>();
    await packageKit.activateService();
    final details = await packageKit.getDetailsLocal(path);
    if (details == null) {
      throw Exception('Failed to get package details');
    }
    final packageName = details.packageId.name;
    final results = await packageKit.resolve([
      packageName,
    ], installedOnly: true);
    final packageInfo = results[packageName];
    return LocalDebData(path: path, details: details, packageInfo: packageInfo);
  }

  Future<void> install() => _runTransaction(
    DebTransactionKind.install,
    () => getService<PackageKitService>().installLocal(path),
  );

  Future<void> remove() async {
    final packageId = state.value?.installedPackageId;
    if (packageId == null) return;
    await _runTransaction(
      DebTransactionKind.remove,
      () => getService<PackageKitService>().remove(packageId),
    );
  }

  Future<void> _runTransaction(
    DebTransactionKind kind,
    Future<int> Function() start,
  ) async {
    if (_busy) return;
    _busy = true;
    final packageKit = getService<PackageKitService>();
    int? transactionId;
    try {
      transactionId = await start();
      if (state.value case final data?) {
        state = AsyncValue.data(
          data.copyWith(
            activeTransactionId: transactionId,
            activeTransactionKind: kind,
          ),
        );
      }
      await packageKit.waitTransaction(transactionId);
    } on PackageKitTransactionCancelled {
      // Dismissing the polkit prompt is not an error.
    } on Exception catch (e) {
      final error = transactionId != null
          ? packageKit.lastErrorFor(transactionId)
          : null;
      ref.read(errorStreamControllerProvider).add(error ?? e);
    } finally {
      _busy = false;
      ref.invalidateSelf();
      // The Manage page lists the same packages.
      ref.invalidate(installedPackagesProvider);
    }
  }

  Future<void> cancel() async {
    final transactionId = state.value?.activeTransactionId;
    if (transactionId == null) return;
    await getService<PackageKitService>().cancelTransaction(transactionId);
    if (state.value case final data?) {
      state = AsyncValue.data(
        data.copyWith(activeTransactionId: null, activeTransactionKind: null),
      );
    }
  }
}
