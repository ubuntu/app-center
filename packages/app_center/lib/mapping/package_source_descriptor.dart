import 'package:app_center/mapping/package_format.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_source_descriptor.freezed.dart';

@freezed
class PackageSourceDescriptor with _$PackageSourceDescriptor {
  const factory PackageSourceDescriptor({
    required PackageFormat format,
    required String packageId,
    String? commonId,
    String? desktopId,
    String? packageName,
    @Default([]) List<String> aliases,
    @Default(false) bool isDesktopApplication,
  }) = _PackageSourceDescriptor;
}
