import 'package:app_center/mapping/identifier_normalization.dart';
import 'package:app_center/mapping/package_format.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/mapping/unified_app_identity.dart';
import 'package:collection/collection.dart';

/// Matching confidence, ordered from strongest to weakest.
enum PackageMatchTier {
  commonId,
  desktopId,
  alias,
  packageName,
}

class PackageMappingResolver {
  const PackageMappingResolver();

  /// Resolves [source] against the available descriptors.
  ///
  /// Candidates are ordered by match confidence, then by stable descriptor
  /// order so resolution does not depend on backend iteration order.
  UnifiedAppIdentity? resolve(
    PackageSourceDescriptor source,
    Iterable<PackageSourceDescriptor> candidates,
  ) {
    final matches =
        candidates
            .where((candidate) => candidate.format != source.format)
            .map(
              (candidate) => (
                candidate: candidate,
                tier: matchTier(source, candidate),
              ),
            )
            .where((match) => match.tier != null)
            .toList()
          ..sort((a, b) {
            final tier = a.tier!.index.compareTo(b.tier!.index);
            if (tier != 0) return tier;
            return _descriptorKey(a.candidate).compareTo(
              _descriptorKey(b.candidate),
            );
          });

    final match = matches.firstOrNull;
    if (match == null) return null;

    final sources = [source, match.candidate]..sort(_compareDescriptors);
    final sharedId = _commonIds(
      source,
    ).intersection(_commonIds(match.candidate)).sorted().firstOrNull;
    final unifiedId = sharedId ?? sources.map(_descriptorKey).join('|');
    // Legacy `.desktop` common IDs are not canonical AppStream IDs.
    final appStreamId =
        sharedId ??
        sources
            .expand(_commonIds)
            .where((id) => !id.endsWith('.desktop'))
            .sorted()
            .firstOrNull ??
        unifiedId;

    return UnifiedAppIdentity(
      unifiedId: unifiedId,
      appStreamId: appStreamId,
      sources: sources,
    );
  }

  PackageMatchTier? matchTier(
    PackageSourceDescriptor first,
    PackageSourceDescriptor second,
  ) {
    if (first.format == second.format) return null;

    if (_commonIds(first).intersection(_commonIds(second)).isNotEmpty) {
      return PackageMatchTier.commonId;
    }

    final desktopIds = _desktopIds(first, second);
    if (desktopIds.$1.isNotEmpty && desktopIds.$1 == desktopIds.$2) {
      return PackageMatchTier.desktopId;
    }

    if (_matchesAlias(first, second)) {
      return PackageMatchTier.alias;
    }

    final firstName = _packageName(first);
    if (first.isDesktopApplication &&
        second.isDesktopApplication &&
        firstName.isNotEmpty &&
        firstName == _packageName(second)) {
      return PackageMatchTier.packageName;
    }

    return null;
  }

  String _packageName(PackageSourceDescriptor source) =>
      normalizeCommonId(source.packageName ?? source.packageId);

  Set<String> _commonIds(PackageSourceDescriptor source) => {
    ...source.commonIds.map(normalizeCommonId),
  }..remove('');

  bool _matchesAlias(
    PackageSourceDescriptor first,
    PackageSourceDescriptor second,
  ) {
    final snap = first.format == PackageFormat.snap ? first : second;
    final deb = first.format == PackageFormat.deb ? first : second;
    if (snap.format != PackageFormat.snap || deb.format != PackageFormat.deb) {
      return false;
    }
    if (_commonIds(
      snap,
    ).map(normalizeDesktopId).toSet().intersection(_aliases(deb)).isNotEmpty) {
      return true;
    }
    // The snap name is compared literally, e.g. against `<provides><binary>`.
    final snapName = normalizeCommonId(snap.packageId);
    return snapName.isNotEmpty &&
        deb.aliases.map(normalizeCommonId).contains(snapName);
  }

  Set<String> _aliases(PackageSourceDescriptor source) => {
    ...source.aliases.map(normalizeDesktopId),
  }..remove('');

  (String, String) _desktopIds(
    PackageSourceDescriptor first,
    PackageSourceDescriptor second,
  ) {
    final snap = switch ((first.format, second.format)) {
      (PackageFormat.snap, _) => first,
      (_, PackageFormat.snap) => second,
      _ => null,
    };
    return (
      normalizeDesktopId(
        first.desktopId,
        snapName: identical(snap, first) ? first.packageId : null,
      ),
      normalizeDesktopId(
        second.desktopId,
        snapName: identical(snap, second) ? second.packageId : null,
      ),
    );
  }

  int _compareDescriptors(
    PackageSourceDescriptor first,
    PackageSourceDescriptor second,
  ) => _descriptorKey(first).compareTo(_descriptorKey(second));

  String _descriptorKey(PackageSourceDescriptor source) =>
      '${source.format.name}:${normalizeCommonId(source.packageId)}';
}
