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
    required PackageKitDetailsEvent? details,
    int? activeTransactionId,
  }) = _LocalDebData;
}

@riverpod
class LocalDebModel extends _$LocalDebModel {
  @override
  Future<LocalDebData> build({required String path}) async {
    final packageKit = getService<PackageKitService>();
    final details = await packageKit.getDetailsLocal(path);
    return LocalDebData(path: path, details: details);
  }

  Future<void> install() async {
    assert(state.hasValue, 'install() called during loading or error state');
    final packageKit = getService<PackageKitService>();
    final activeTransactionId = await packageKit.installLocal(path);
    state = AsyncValue.data(
        state.value!.copyWith(activeTransactionId: activeTransactionId));
    await packageKit.waitTransaction(activeTransactionId);
    state = AsyncValue.data(state.value!.copyWith(activeTransactionId: null));
  }
}
