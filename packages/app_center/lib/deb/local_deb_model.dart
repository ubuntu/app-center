import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_model.freezed.dart';
part 'local_deb_model.g.dart';

enum LocalDebTransactionKind { install, remove }

@freezed
abstract class LocalDebData extends AppMetadata with _$LocalDebData {
  factory LocalDebData({
    required String path,
    required PackageKitDetailsEvent details,
    PackageKitPackageInfo? packageInfo,
    int? activeTransactionId,
    LocalDebTransactionKind? activeTransactionKind,
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

  Future<void> install() async {
    assert(state.hasValue, 'install() called during loading or error state');
    final packageKit = getService<PackageKitService>();
    final activeTransactionId = await packageKit.installLocal(path);
    state = AsyncValue.data(
      state.value!.copyWith(
        activeTransactionId: activeTransactionId,
        activeTransactionKind: LocalDebTransactionKind.install,
      ),
    );
    await _waitAndRefresh(activeTransactionId);
  }

  Future<void> remove() async {
    final packageId = state.value?.installedPackageId;
    assert(packageId != null, 'remove() called without an installed package');
    final packageKit = getService<PackageKitService>();
    final activeTransactionId = await packageKit.remove(packageId!);
    state = AsyncValue.data(
      state.value!.copyWith(
        activeTransactionId: activeTransactionId,
        activeTransactionKind: LocalDebTransactionKind.remove,
      ),
    );
    await _waitAndRefresh(activeTransactionId);
  }

  Future<void> _waitAndRefresh(int transactionId) async {
    final packageKit = getService<PackageKitService>();
    try {
      await packageKit.waitTransaction(transactionId);
    } on PackageKitTransactionCancelled {
      // Dismissing the polkit prompt is not an error.
    } on PackageKitTransactionError catch (e) {
      ref
          .read(errorStreamControllerProvider)
          .add(packageKit.lastErrorFor(transactionId) ?? e);
    } finally {
      ref.invalidateSelf();
    }
  }

  Future<void> cancel() async {
    assert(
      state.value?.activeTransactionId != null,
      'cancel() called without active transaction',
    );
    final packageKit = getService<PackageKitService>();
    await packageKit.cancelTransaction(state.value!.activeTransactionId!);
    state = AsyncValue.data(
      state.value!.copyWith(
        activeTransactionId: null,
        activeTransactionKind: null,
      ),
    );
  }

  Stream<PackageKitServiceError> get errorStream =>
      getService<PackageKitService>().errorStream;
}
