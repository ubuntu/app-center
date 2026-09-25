import 'package:app_center/mapping/deb_package_adapter.dart';
import 'package:app_center/mapping/identifier_normalization.dart';
import 'package:app_center/mapping/package_format.dart';
import 'package:app_center/mapping/package_format_adapter.dart';
import 'package:app_center/mapping/package_mapping_resolver.dart';
import 'package:app_center/mapping/package_runtime_state.dart';
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

      candidates.addAll(await _lookupCandidates(adapter, source));
    }

    return _resolver.resolve(source, candidates);
  }

  Future<List<PackageSourceDescriptor>> _lookupCandidates(
    PackageFormatAdapter adapter,
    PackageSourceDescriptor source,
  ) async {
    if (source.commonIds.isNotEmpty) {
      final candidates = (await Future.wait(
        source.commonIds.map(adapter.findByCommonId),
      )).whereType<PackageSourceDescriptor>().toList();
      if (candidates.isNotEmpty) return candidates;
    }
    final desktopId = normalizeDesktopId(
      source.desktopId,
      snapName: source.format == PackageFormat.snap ? source.packageId : null,
    );
    if (desktopId.isNotEmpty) {
      final candidate = await adapter.findByDesktopId(desktopId);
      if (candidate != null) return [candidate];
    }
    if (source.format == PackageFormat.snap &&
        adapter.format == PackageFormat.deb) {
      final candidates = (await Future.wait(
        [...source.commonIds, source.packageId].map(adapter.findByAlias),
      )).whereType<PackageSourceDescriptor>().toList();
      if (candidates.isNotEmpty) return candidates;
    }
    if (source.format == PackageFormat.deb &&
        adapter.format == PackageFormat.snap) {
      final candidates = (await Future.wait(
        source.aliases.map(adapter.findByCommonId),
      )).whereType<PackageSourceDescriptor>().toList();
      if (candidates.isNotEmpty) return candidates;
    }
    if (source.packageName != null && source.packageName!.isNotEmpty) {
      final candidate = await adapter.findByPackageName(source.packageName!);
      return candidate == null ? [] : [candidate];
    }
    final candidate = await adapter.findByPackageName(source.packageId);
    return candidate == null ? [] : [candidate];
  }
}

class PackageRuntimeStateService {
  PackageRuntimeStateService({List<PackageFormatAdapter>? adapters})
    : _adapters = adapters ?? _defaultAdapters();

  static List<PackageFormatAdapter> _defaultAdapters() => [
    DebPackageAdapter(),
    SnapPackageAdapter(),
  ];

  final List<PackageFormatAdapter> _adapters;

  Future<Map<PackageFormat, PackageRuntimeState>> getIdentityState(
    UnifiedAppIdentity identity,
  ) async {
    final states = <PackageFormat, PackageRuntimeState>{};
    for (final source in identity.sources) {
      states[source.format] = await _adapterFor(
        source.format,
      ).getRuntimeState(source.packageId);
    }
    return Map.unmodifiable(states);
  }

  PackageFormatAdapter _adapterFor(PackageFormat format) {
    return _adapters.firstWhere(
      (adapter) => adapter.format == format,
      orElse: () => throw StateError(
        'PackageRuntimeStateService has no adapter for $format',
      ),
    );
  }
}
