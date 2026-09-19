import 'package:app_center/mapping/deb_package_adapter.dart';
import 'package:app_center/mapping/package_format_adapter.dart';
import 'package:app_center/mapping/package_mapping_resolver.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/mapping/snap_package_adapter.dart';
import 'package:app_center/mapping/unified_app_identity.dart';

class PackageMappingService {
  PackageMappingService({
    List<PackageFormatAdapter>? adapters,
    PackageMappingResolver? resolver,
  }) : _adapters = adapters ?? _defaultAdapters(),
       _resolver = resolver ?? const PackageMappingResolver();

  static List<PackageFormatAdapter> _defaultAdapters() => [
    DebPackageAdapter(),
    SnapPackageAdapter(),
  ];

  final List<PackageFormatAdapter> _adapters;
  final PackageMappingResolver _resolver;

  Future<UnifiedAppIdentity?> resolve(PackageSourceDescriptor source) async {
    final candidates = <PackageSourceDescriptor>[];

    for (final adapter in _adapters) {
      if (adapter.format == source.format) continue;

      final lookupKey =
          source.commonId ??
          source.desktopId ??
          source.packageName ??
          source.packageId;
      final candidate = await _lookupCandidate(adapter, source, lookupKey);
      if (candidate != null) {
        candidates.add(candidate);
      }
    }

    return _resolver.resolve(source, candidates);
  }

  Future<PackageSourceDescriptor?> _lookupCandidate(
    PackageFormatAdapter adapter,
    PackageSourceDescriptor source,
    String lookupKey,
  ) async {
    if (source.commonId != null) {
      return adapter.findByCommonId(source.commonId!);
    }
    if (source.desktopId != null) {
      return adapter.findByDesktopId(source.desktopId!);
    }
    if (source.packageName != null && source.packageName!.isNotEmpty) {
      return adapter.findByPackageName(source.packageName!);
    }
    return adapter.findByPackageName(lookupKey);
  }
}
