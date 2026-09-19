import 'package:app_center/mapping/package_format.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unified_app_identity.freezed.dart';

@freezed
class UnifiedAppIdentity with _$UnifiedAppIdentity {
  const factory UnifiedAppIdentity({
    required String unifiedId,
    required String appStreamId,
    required List<PackageSourceDescriptor> sources,
  }) = _UnifiedAppIdentity;

  const UnifiedAppIdentity._();

  bool hasFormat(PackageFormat format) =>
      sources.any((source) => source.format == format);

  PackageSourceDescriptor? getSource(PackageFormat format) =>
      sources.firstWhereOrNull((source) => source.format == format);
}
