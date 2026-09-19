import 'package:app_center/mapping/mapping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resolver = PackageMappingResolver();

  test('normalizes common and desktop identifiers', () {
    expect(normalizeCommonId(' Org.Videolan.VLC '), 'org.videolan.vlc');
    expect(normalizeDesktopId(' VLC.DESKTOP '), 'vlc');
    expect(
      normalizeDesktopId('VLC_VLC.DESKTOP', snapName: 'vlc'),
      'vlc',
    );
    expect(
      normalizeDesktopId('my_app_launcher.desktop', snapName: 'my_app'),
      'launcher',
    );
  });

  test('matches canonical common IDs first', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonId: 'org.videolan.vlc',
      desktopId: 'vlc.desktop',
      packageName: 'vlc',
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonId: 'ORG.VIDEOLAN.VLC',
      desktopId: 'vlc_vlc.desktop',
      packageName: 'vlc',
      isDesktopApplication: true,
    );

    expect(resolver.matchTier(deb, snap), PackageMatchTier.commonId);
  });

  test('matches desktop IDs after removing the Snap prefix', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      desktopId: 'vlc.desktop',
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      desktopId: 'vlc_vlc.desktop',
      isDesktopApplication: true,
    );

    expect(resolver.matchTier(deb, snap), PackageMatchTier.desktopId);
  });

  test('matches AppStream aliases', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'gimp',
      aliases: ['gimp.desktop'],
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'gimp',
      commonId: 'gimp.desktop',
      isDesktopApplication: true,
    );

    expect(resolver.matchTier(deb, snap), PackageMatchTier.alias);
  });

  test('uses package names only for desktop applications', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc-deb',
      packageName: 'vlc',
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      isDesktopApplication: true,
    );
    final nonDesktopDeb = deb.copyWith(isDesktopApplication: false);

    expect(resolver.matchTier(deb, snap), PackageMatchTier.packageName);
    expect(resolver.matchTier(nonDesktopDeb, snap), isNull);
  });

  test('resolves the strongest candidate and sorts sources', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonId: 'org.videolan.vlc',
    );
    final aliasCandidate = const PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc-alias',
      aliases: ['org.videolan.vlc'],
    );
    final canonicalCandidate = const PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonId: 'org.videolan.vlc',
    );

    final identity = resolver.resolve(deb, [
      aliasCandidate,
      canonicalCandidate,
    ]);

    expect(identity, isNotNull);
    expect(identity!.unifiedId, 'org.videolan.vlc');
    expect(identity.appStreamId, 'org.videolan.vlc');
    expect(identity.sources, [deb, canonicalCandidate]);
  });

  test('uses a deterministic fallback identity without a common ID', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      packageName: 'vlc',
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      isDesktopApplication: true,
    );

    final identity = resolver.resolve(deb, [snap]);

    expect(identity, isNotNull);
    expect(identity!.unifiedId, 'deb:vlc|snap:vlc');
    expect(identity.appStreamId, identity.unifiedId);
  });

  test('does not match sources from the same format', () {
    const first = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonId: 'org.videolan.vlc',
    );
    const second = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc-edge',
      commonId: 'org.videolan.vlc',
    );

    expect(resolver.matchTier(first, second), isNull);
    expect(resolver.resolve(first, [second]), isNull);
  });
}
