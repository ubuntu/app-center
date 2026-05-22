import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/deb/deb_architecture.dart';
import 'package:app_center/deb/local_deb_exceptions.dart';
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
    PackageKitPackageInfo? packageInfo,
    int? activeTransactionId,
    PackageKitServiceError? error,
  }) = _LocalDebData;

  LocalDebData._();

  bool get isInstalled => packageInfo?.info == PackageKitInfo.installed;

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
    final packageArch = details.packageId.arch;
    final systemArch = await packageKit.getNativeArchitecture();
    if (!isDebArchitectureCompatible(
      packageArch: packageArch,
      systemArch: systemArch,
    )) {
      throw DebArchitectureMismatchException(
        packageArch: packageArch,
        systemArch: systemArch,
      );
    }
    final packageName = details.packageId.name;
    final results = await packageKit.resolve([packageName]);
    final packageInfo = results[packageName];

    final errorListener = packageKit.errorStream.listen(_onError);
    ref.onDispose(errorListener.cancel);

    return LocalDebData(path: path, details: details, packageInfo: packageInfo);
  }

  Future<void> install() async {
    assert(state.hasValue, 'install() called during loading or error state');
    final packageKit = getService<PackageKitService>();
    final activeTransactionId = await packageKit.installLocal(path);
    state = AsyncValue.data(
      state.value!.copyWith(activeTransactionId: activeTransactionId),
    );
    try {
      await packageKit.waitTransaction(activeTransactionId);
      ref.invalidateSelf();
    } on Exception {
      // The transaction failed. If it emitted a PackageKit error code, _onError
      // has already recorded it and cleared activeTransactionId; a second update
      // here would re-trigger the error dialog, so only clear the spinner when
      // it is still set — i.e. for failures with no error code (a destroyed
      // transaction or a closed stream), so the spinner never gets stuck.
      if (state.value?.activeTransactionId != null) {
        state =
            AsyncValue.data(state.value!.copyWith(activeTransactionId: null));
      }
    }
  }

  Future<void> _onError(PackageKitServiceError error) async {
    state = AsyncValue.data(
      state.value!.copyWith(
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
