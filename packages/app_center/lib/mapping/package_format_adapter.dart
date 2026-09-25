import 'package:app_center/mapping/package_format.dart';
import 'package:app_center/mapping/package_runtime_state.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';

abstract class PackageFormatAdapter {
  PackageFormat get format;

  Future<void> initialize();

  Future<PackageSourceDescriptor?> findByCommonId(String commonId);

  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId);

  Future<PackageSourceDescriptor?> findByAlias(String alias) async => null;

  Future<PackageSourceDescriptor?> findByPackageName(String packageName);

  Future<PackageRuntimeState> getRuntimeState(String packageId);
}
