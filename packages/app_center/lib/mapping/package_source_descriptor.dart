import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_source_descriptor.freezed.dart';

enum PackageFormat { snap, deb }

@freezed
class PackageSourceDescriptor with _$PackageSourceDescriptor {
  const factory PackageSourceDescriptor({
    required PackageFormat format,
    required String packageId,
    @Default([]) List<String> commonIds,
    String? desktopId,
    String? packageName,
    @Default([]) List<String> aliases,
    @Default(false) bool isDesktopApplication,
  }) = _PackageSourceDescriptor;
}
