import 'package:freezed_annotation/freezed_annotation.dart';

part 'drivers_model.freezed.dart';

/// The source of a [DriverPackage].
enum DriverSource {
  distro,
  thirdParty,
  unknown;

  factory DriverSource.fromString(String value) => switch (value) {
    'distro' => DriverSource.distro,
    'third-party' => DriverSource.thirdParty,
    _ => DriverSource.unknown,
  };
}

/// A single driver package that can be installed for a [DriverDevice].
@freezed
class DriverPackage with _$DriverPackage {
  const factory DriverPackage({
    required String name,
    required DriverSource source,
    required bool free,
    required bool builtin,
    required bool recommended,
    required String support,
    @Default(false) bool openPreferred,
  }) = _DriverPackage;
}

/// A hardware device detected by the `com.ubuntu.Drivers` D-Bus service,
/// along with the driver packages available for it.
@freezed
class DriverDevice with _$DriverDevice {
  const factory DriverDevice({
    required String sysPath,
    required String modalias,
    required String vendor,
    required String model,
    required List<DriverPackage> drivers,
  }) = _DriverDevice;
}
