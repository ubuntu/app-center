import 'dart:io';

import 'package:app_center/packagekit.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'local_deb_model.freezed.dart';
part 'local_deb_model.g.dart';

final _log = Logger('local_deb_model');

@freezed
class LocalDebData with _$LocalDebData {
  factory LocalDebData({
    required String path,
    required PackageKitDetailsEvent? details,
    int? activeTransactionId,
  }) = _LocalDebData;
}

@riverpod
FileSystem fs(FsRef ref) {
  assert(!Platform.environment.containsKey('FLUTTER_TEST'));
  return const LocalFileSystem();
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
    if (!state.hasValue) return;
    final file = ref.read(fsProvider).file(state.value!.path);
    if (!file.existsSync()) {
      _log.error('File ${state.value!.path} does not exist');
      return;
    }
    final packageKit = getService<PackageKitService>();
    final activeTransactionId = await packageKit.installLocal(file.path);
    state = AsyncValue.data(
        state.value!.copyWith(activeTransactionId: activeTransactionId));
    await packageKit.waitTransaction(activeTransactionId);
    state = AsyncValue.data(state.value!.copyWith(activeTransactionId: null));
  }
}
