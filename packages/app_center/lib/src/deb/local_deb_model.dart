import 'package:app_center/packagekit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_model.freezed.dart';
part 'local_deb_model.g.dart';

@freezed
class LocalDebData with _$LocalDebData {
  factory LocalDebData({
    required String path,
    required PackageKitDetailsEvent details,
    PackageKitPackageInfo? packageInfo,
    int? activeTransactionId,
  }) = _LocalDebData;

  LocalDebData._();

  bool get isInstalled => packageInfo?.info == PackageKitInfo.installed;
}

@riverpod
class LocalDebModel extends _$LocalDebModel {
  @override
  Future<LocalDebData> build({required String path}) async {
    final packageKit = getService<PackageKitService>();
    final details = await packageKit.getDetailsLocal(path);
    if (details == null) {
      throw StateError('Failed to get package details');
    }
    final packageInfo = await packageKit.resolve(details.packageId.name);
    return LocalDebData(path: path, details: details, packageInfo: packageInfo);
  }

  Future<void> install() async {
    assert(state.hasValue, 'install() called during loading or error state');
    final packageKit = getService<PackageKitService>();
    final activeTransactionId = await packageKit.installLocal(path);
    state = AsyncValue.data(
        state.value!.copyWith(activeTransactionId: activeTransactionId));
    await packageKit.waitTransaction(activeTransactionId);
    ref.invalidateSelf();
  }

  Future<void> cancel() async {
    assert(state.asData?.value.activeTransactionId != null,
        'cancel() called without active transaction');
    final packageKit = getService<PackageKitService>();
    await packageKit
        .cancelTransaction(state.asData!.value.activeTransactionId!);
    state = AsyncValue.data(state.value!.copyWith(activeTransactionId: null));
  }

  Stream<PackageKitServiceError> get errorStream =>
      getService<PackageKitService>().errorStream;
}
