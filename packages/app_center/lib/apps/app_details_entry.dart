import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/mapping/deb_package_adapter.dart';
import 'package:app_center/mapping/package_format_adapter.dart';
import 'package:app_center/mapping/package_mapping_service.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/mapping/snap_package_adapter.dart';
import 'package:app_center/mapping/unified_app_identity.dart';
import 'package:app_center/snapd/snap_data.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'app_details_entry.freezed.dart';
part 'app_details_entry.g.dart';

/// Typed input for opening the unified details page.
@freezed
sealed class AppDetailsEntry with _$AppDetailsEntry {
  const factory AppDetailsEntry.snap(String snapName) = SnapNameEntry;
  const factory AppDetailsEntry.debComponent(String componentId) =
      DebComponentEntry;
  const factory AppDetailsEntry.identity(UnifiedAppIdentity identity) =
      IdentityEntry;

  factory AppDetailsEntry.fromSnapData(SnapData data) =>
      AppDetailsEntry.snap(data.name);

  factory AppDetailsEntry.fromDebData(DebData data) =>
      AppDetailsEntry.debComponent(data.id);

  const AppDetailsEntry._();

  bool get isValid => when(
    snap: (name) => name.trim().isNotEmpty,
    debComponent: (id) => id.trim().isNotEmpty,
    identity: (identity) => identity.sources.any(
      (source) => SourceKey.fromDescriptor(source) != null,
    ),
  );

  /// Identity of the entry's own source, used until lookup completes.
  ResolvedAppIdentity get provisionalIdentity => when(
    snap: (name) =>
        ResolvedAppIdentity(identity: singleSourceIdentity(_snapSource(name))),
    debComponent: (id) =>
        ResolvedAppIdentity(identity: singleSourceIdentity(_debSource(id))),
    identity: (identity) => ResolvedAppIdentity(identity: identity),
  );

  /// Key of the source the entry names, if it names a single one.
  SourceKey? get sourceKey =>
      this is IdentityEntry ? null : provisionalIdentity.sourceKeys.firstOrNull;
}

PackageSourceDescriptor _snapSource(String name) => PackageSourceDescriptor(
  format: PackageFormat.snap,
  packageId: name,
  packageName: name,
);

PackageSourceDescriptor _debSource(String id) => PackageSourceDescriptor(
  format: PackageFormat.deb,
  packageId: id,
  commonIds: [id],
);

/// Canonical key of one package source, in its backend's own namespace.
///
/// Snap: snap name. Deb: AppStream component ID.
@freezed
abstract class SourceKey with _$SourceKey {
  const factory SourceKey({
    required PackageFormat format,
    required String id,
  }) = _SourceKey;

  const SourceKey._();

  static SourceKey? fromDescriptor(PackageSourceDescriptor source) {
    final id = switch (source.format) {
      PackageFormat.snap => source.packageId,
      PackageFormat.deb => source.commonIds.firstWhereOrNull(
        (id) => id.trim().isNotEmpty,
      ),
    };
    if (id == null || id.trim().isEmpty) return null;
    return SourceKey(format: source.format, id: id);
  }

  String get value => '${format.name}:$id';
}

class InvalidAppDetailsEntry implements Exception {
  const InvalidAppDetailsEntry(this.entry);

  final AppDetailsEntry entry;

  @override
  String toString() => 'InvalidAppDetailsEntry($entry)';
}

/// Every source of the app is confirmed to no longer exist.
class AppNotFound implements Exception {
  const AppNotFound(this.entry);

  final AppDetailsEntry entry;

  @override
  String toString() => 'AppNotFound($entry)';
}

@freezed
abstract class ResolvedAppIdentity with _$ResolvedAppIdentity {
  const factory ResolvedAppIdentity({
    required UnifiedAppIdentity identity,
    // Lookup failed, so counterparts may be missing; not a confirmed no-match.
    @Default(false) bool discoveryFailed,
  }) = _ResolvedAppIdentity;

  const ResolvedAppIdentity._();

  List<SourceKey> get sourceKeys =>
      identity.sources
          .map(SourceKey.fromDescriptor)
          .whereType<SourceKey>()
          .toSet()
          .toList()
        ..sort((a, b) => a.format.index.compareTo(b.format.index));
}

class AppDetailsIdentityResolver {
  AppDetailsIdentityResolver({
    required this._snapAdapter,
    required this._debAdapter,
    required this._mappingService,
  });

  final PackageFormatAdapter _snapAdapter;
  final PackageFormatAdapter _debAdapter;
  final PackageMappingService _mappingService;

  Future<ResolvedAppIdentity> resolve(AppDetailsEntry entry) async {
    if (!entry.isValid) throw InvalidAppDetailsEntry(entry);

    return entry.when(
      identity: (identity) async => ResolvedAppIdentity(identity: identity),
      snap: (name) => _resolve(
        _snapSource(name),
        () => _snapAdapter.findByPackageName(name),
      ),
      debComponent: (id) => _resolve(
        _debSource(id),
        () => _debAdapter.findByCommonId(id),
      ),
    );
  }

  Future<ResolvedAppIdentity> _resolve(
    PackageSourceDescriptor fallback,
    Future<PackageSourceDescriptor?> Function() lookup,
  ) async {
    PackageSourceDescriptor source;
    try {
      source = _preserveKey(await lookup(), fallback);
    } on Exception {
      return ResolvedAppIdentity(
        identity: singleSourceIdentity(fallback),
        discoveryFailed: true,
      );
    }

    try {
      final identity = await _mappingService.resolve(source);
      return ResolvedAppIdentity(
        identity: identity ?? singleSourceIdentity(source),
      );
    } on Exception {
      return ResolvedAppIdentity(
        identity: singleSourceIdentity(source),
        discoveryFailed: true,
      );
    }
  }

  // A lookup may return a different component of the same package.
  PackageSourceDescriptor _preserveKey(
    PackageSourceDescriptor? found,
    PackageSourceDescriptor fallback,
  ) {
    if (found == null) return fallback;
    if (SourceKey.fromDescriptor(found) == SourceKey.fromDescriptor(fallback)) {
      return found;
    }
    return found.copyWith(
      packageId: fallback.format == PackageFormat.snap
          ? fallback.packageId
          : found.packageId,
      commonIds: {...fallback.commonIds, ...found.commonIds}.toList(),
    );
  }
}

/// Identity for a source with no known counterpart.
UnifiedAppIdentity singleSourceIdentity(PackageSourceDescriptor source) {
  final unifiedId = '${source.format.name}:${source.packageId}';
  return UnifiedAppIdentity(
    unifiedId: unifiedId,
    appStreamId:
        source.commonIds.firstWhereOrNull((id) => !id.endsWith('.desktop')) ??
        unifiedId,
    sources: [source],
  );
}

@Riverpod(keepAlive: true)
AppDetailsIdentityResolver appDetailsIdentityResolver(Ref ref) =>
    AppDetailsIdentityResolver(
      snapAdapter: getService<SnapPackageAdapter>(),
      debAdapter: getService<DebPackageAdapter>(),
      mappingService: getService<PackageMappingService>(),
    );

@riverpod
Future<ResolvedAppIdentity> appDetailsIdentity(
  Ref ref,
  AppDetailsEntry entry,
) async {
  final resolved = await ref
      .watch(appDetailsIdentityResolverProvider)
      .resolve(entry);
  // Failed lookups aren't shared, and abandoned ones must not replace a newer
  // result. The lookup still runs again on every open.
  if (!resolved.discoveryFailed && ref.mounted) {
    ref.read(knownAppIdentitiesProvider.notifier).record(resolved);
  }
  return resolved;
}

/// Last successful lookup by every source it includes, shown while a page's
/// own lookup runs, including for an app opened from its other format.
@Riverpod(keepAlive: true)
class KnownAppIdentities extends _$KnownAppIdentities {
  @override
  Map<SourceKey, ResolvedAppIdentity> build() => const {};

  void record(ResolvedAppIdentity identity) {
    state = Map.unmodifiable({
      ...state,
      for (final key in identity.sourceKeys) key: identity,
    });
  }
}
