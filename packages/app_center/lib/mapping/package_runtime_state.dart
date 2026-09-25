import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_runtime_state.freezed.dart';

@freezed
class PackageRuntimeState with _$PackageRuntimeState {
  const factory PackageRuntimeState({
    required bool isInstalled,
    String? installedVersion,
    String? availableVersion,
    String? channelOrOrigin,
    @Default(false) bool hasUpdate,
    @Default(false) bool isBusy,
  }) = _PackageRuntimeState;
}
