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
    expect(
      normalizeDesktopId(
        '/var/lib/snapd/desktop/applications/vlc_vlc.desktop',
        snapName: 'vlc',
      ),
      'vlc',
    );
  });

  test('matches canonical common IDs first', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
      desktopId: 'vlc.desktop',
      packageName: 'vlc',
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonIds: ['org.example.vlc', 'ORG.VIDEOLAN.VLC'],
      desktopId: 'vlc_vlc.desktop',
      packageName: 'vlc',
      isDesktopApplication: true,
    );

    expect(resolver.matchTier(deb, snap), PackageMatchTier.commonId);
  });

  test('matches any normalized common ID', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonIds: ['org.example.legacy', ' ORG.VIDEOLAN.VLC '],
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
      commonIds: ['gimp.desktop'],
      isDesktopApplication: true,
    );

    expect(resolver.matchTier(deb, snap), PackageMatchTier.alias);
  });

  test('does not use Snap app aliases for Tier 3', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'gimp',
      aliases: ['gimp.desktop'],
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'gimp',
      aliases: ['gimp.desktop'],
    );

    expect(resolver.matchTier(deb, snap), isNull);
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
      commonIds: ['org.videolan.vlc'],
    );
    final aliasCandidate = const PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc-alias',
      aliases: ['org.videolan.vlc'],
    );
    final canonicalCandidate = const PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
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
      commonIds: ['org.videolan.vlc'],
    );
    const second = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc-edge',
      commonIds: ['org.videolan.vlc'],
    );

    expect(resolver.matchTier(first, second), isNull);
    expect(resolver.resolve(first, [second]), isNull);
  });

  group('tier precedence', () {
    test('common ID beats desktop ID', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'vlc',
        commonIds: ['org.videolan.vlc'],
        desktopId: 'vlc.desktop',
      );
      const desktopMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'a-vlc',
        desktopId: 'a-vlc_vlc.desktop',
      );
      const commonMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'z-vlc',
        commonIds: ['org.videolan.vlc'],
      );

      final identity = resolver.resolve(deb, [desktopMatch, commonMatch]);

      expect(identity!.getSource(PackageFormat.snap), commonMatch);
    });

    test('desktop ID beats alias', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'vlc',
        desktopId: 'vlc.desktop',
        aliases: ['vlc-legacy.desktop'],
      );
      const aliasMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'a-vlc',
        commonIds: ['vlc-legacy.desktop'],
      );
      const desktopMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'z-vlc',
        desktopId: 'z-vlc_vlc.desktop',
      );

      final identity = resolver.resolve(deb, [aliasMatch, desktopMatch]);

      expect(identity!.getSource(PackageFormat.snap), desktopMatch);
    });

    test('desktop ID beats package name', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'vlc',
        packageName: 'vlc',
        desktopId: 'vlc.desktop',
        isDesktopApplication: true,
      );
      const nameMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'vlc',
        isDesktopApplication: true,
      );
      const desktopMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'z-vlc',
        desktopId: 'z-vlc_vlc.desktop',
        isDesktopApplication: true,
      );

      final identity = resolver.resolve(deb, [nameMatch, desktopMatch]);

      expect(identity!.getSource(PackageFormat.snap), desktopMatch);
    });

    test('alias beats package name', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'gimp',
        packageName: 'gimp',
        aliases: ['gimp.desktop'],
        isDesktopApplication: true,
      );
      const nameMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'gimp',
        isDesktopApplication: true,
      );
      const aliasMatch = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'z-gimp',
        commonIds: ['gimp.desktop'],
        isDesktopApplication: true,
      );

      final identity = resolver.resolve(deb, [nameMatch, aliasMatch]);

      expect(identity!.getSource(PackageFormat.snap), aliasMatch);
    });
  });

  group('determinism', () {
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
    );
    const first = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc-a',
      commonIds: ['org.videolan.vlc'],
    );
    const second = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc-b',
      commonIds: ['org.videolan.vlc'],
    );

    test('picks the same equal-tier candidate', () {
      final forward = resolver.resolve(deb, [first, second]);
      final reversed = resolver.resolve(deb, [second, first]);

      expect(forward!.getSource(PackageFormat.snap), first);
      expect(reversed, forward);
    });

    test('repeated resolution is stable', () {
      expect(
        resolver.resolve(deb, [first, second]),
        resolver.resolve(deb, [first, second]),
      );
    });

    test('picks the same shared common ID', () {
      const debMulti = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'app',
        commonIds: ['org.b.app', 'org.a.app'],
      );
      const snapMulti = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'app',
        commonIds: ['org.a.app', 'org.b.app'],
      );

      final fromDeb = resolver.resolve(debMulti, [snapMulti]);
      final fromSnap = resolver.resolve(snapMulti, [debMulti]);

      expect(fromDeb!.unifiedId, 'org.a.app');
      expect(fromSnap, fromDeb);
    });

    test('ignores duplicate candidates', () {
      final identity = resolver.resolve(deb, [first, first]);

      expect(identity!.sources, [deb, first]);
    });
  });

  group('alias', () {
    test('keeps the canonical ID', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'gimp',
        commonIds: ['org.gimp.gimp'],
        aliases: ['gimp.desktop'],
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'gimp',
        commonIds: ['gimp.desktop'],
      );

      final identity = resolver.resolve(deb, [snap]);

      expect(identity!.appStreamId, 'org.gimp.gimp');
    });

    test('matches the snap name', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'gimp-deb',
        aliases: ['gimp'],
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'gimp',
      );

      expect(resolver.matchTier(deb, snap), PackageMatchTier.alias);
    });

    test('ignores unrelated aliases', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'foo',
        aliases: ['foo.desktop'],
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'bar',
        commonIds: ['bar.desktop'],
      );

      expect(resolver.matchTier(deb, snap), isNull);
    });
  });

  group('no match', () {
    test('empty identifiers', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'foo',
        commonIds: [' '],
        desktopId: ' ',
        aliases: [''],
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'bar',
        commonIds: [''],
        desktopId: '   ',
      );

      expect(resolver.matchTier(deb, snap), isNull);
    });

    test('empty package names', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'foo',
        packageName: '',
        isDesktopApplication: true,
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'bar',
        packageName: '',
        isDesktopApplication: true,
      );

      expect(resolver.matchTier(deb, snap), isNull);
    });

    test('desktop ID with another snap prefix', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'vlc',
        desktopId: 'vlc.desktop',
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'other',
        desktopId: 'vlc_vlc.desktop',
      );

      expect(resolver.matchTier(deb, snap), isNull);
    });

    test('snap prefix on the deb side', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'vlc',
        desktopId: 'vlc_vlc.desktop',
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'vlc',
        desktopId: 'vlc.desktop',
      );

      expect(resolver.matchTier(deb, snap), isNull);
    });

    test('non-desktop package names', () {
      const deb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'curl',
        packageName: 'curl',
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'curl',
      );

      expect(resolver.resolve(deb, [snap]), isNull);
    });
  });
}
