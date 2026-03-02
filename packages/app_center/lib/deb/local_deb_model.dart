import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:appstream/appstream.dart';
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
  Map<AppstreamUrlType, String>? get links => {
        AppstreamUrlType.homepage: details.url,
      };

  @override
  DateTime? get published => null;

  @override
  String? get version => details.packageId.version;
}

@riverpod
class LocalDebModel extends _$LocalDebModel {
  @override
  Future<LocalDebData> build({required String path}) async {
    final packageKit = getService<PackageKitService>();
    await packageKit.activateService();
    final details = await packageKit.getDetailsLocal(path);
    if (details == null) {
      throw Exception('Failed to get package details');
    }
    final packageInfo = await packageKit.resolve(details.packageId.name);
    return LocalDebData(path: path, details: details, packageInfo: packageInfo);
  }

  Future<void> install() async {
    assert(state.hasValue, 'install() called during loading or error state');
    final packageKit = getService<PackageKitService>();
    final activeTransactionId = await packageKit.installLocal(path);
    state = AsyncValue.data(
      state.value!.copyWith(activeTransactionId: activeTransactionId),
    );
    await packageKit.waitTransaction(activeTransactionId);
    ref.invalidateSelf();
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

  Stream<PackageKitServiceError> get errorStream =>
      getService<PackageKitService>().errorStream;
}
