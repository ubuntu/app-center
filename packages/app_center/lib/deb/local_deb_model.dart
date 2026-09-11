import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/deb/deb_architecture.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_model.freezed.dart';
part 'local_deb_model.g.dart';

@freezed
class LocalDebData extends AppMetadata with _$LocalDebData {
  factory LocalDebData({
    required String path,
    required PackageKitDetailsEvent details,
    required String systemArch,
    PackageKitPackageInfo? packageInfo,
    int? activeTransactionId,
    PackageKitServiceError? error,
  }) = _LocalDebData;

  LocalDebData._();

  bool get isInstalled => packageInfo?.info == PackageKitInfo.installed;

  /// Whether this `.deb` is built for an architecture the system can execute.
  /// When `false` the page stays fully visible, but installing is disabled.
  bool get isArchitectureCompatible => isDebArchitectureCompatible(
    packageArch: details.packageId.arch,
    systemArch: systemArch,
  );

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
    final systemArch = await packageKit.getNativeArchitecture();
    final packageName = details.packageId.name;
    final results = await packageKit.resolve([packageName]);
    final packageInfo = results[packageName];

    final errorListener = packageKit.errorStream.listen(_onError);
    ref.onDispose(errorListener.cancel);

    return LocalDebData(
      path: path,
      details: details,
      systemArch: systemArch,
      packageInfo: packageInfo,
    );
  }

  Future<void> install() async {
    assert(state.hasValue, 'install() called during loading or error state');
    final packageKit = getService<PackageKitService>();
    final errorBefore = state.value!.error;
    try {
      final activeTransactionId = await packageKit.installLocal(path);
      state = AsyncValue.data(
        state.value!.copyWith(activeTransactionId: activeTransactionId),
      );
      await packageKit.waitTransaction(activeTransactionId);
      ref.invalidateSelf();
    } on Exception catch (e) {
      // Failures that emit a PackageKit error code have already been recorded
      // by _onError; any other failure (creating the transaction, a destroyed
      // transaction, a closed stream) would otherwise be silent, so record a
      // generic error for it. Either way the spinner is cleared.
      final data = state.valueOrNull;
      if (data == null) return;
      final recorded = identical(data.error, errorBefore) ? null : data.error;
      state = AsyncValue.data(
        data.copyWith(
          error:
              recorded ??
              PackageKitServiceError(
                code: PackageKitError.unknown,
                details: e.toString(),
              ),
          activeTransactionId: null,
        ),
      );
    }
  }

  void _onError(PackageKitServiceError error) {
    final data = state.valueOrNull;
    if (data == null) return;
    state = AsyncValue.data(
      data.copyWith(
        error: error,
        activeTransactionId: null,
      ),
    );
  }

  Future<void> cancel() async {
    assert(
      state.value?.activeTransactionId != null,
      'cancel() called without active transaction',
    );
    final packageKit = getService<PackageKitService>();
    await packageKit.cancelTransaction(state.value!.activeTransactionId!);
    state = AsyncValue.data(state.value!.copyWith(activeTransactionId: null));
  }
}
