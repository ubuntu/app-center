import 'package:app_center/mapping/mapping.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

class _FakeAdapter implements PackageFormatAdapter {
  _FakeAdapter(this.format, this.descriptors);

  @override
  final PackageFormat format;

  final List<PackageSourceDescriptor> descriptors;

  @override
  Future<void> initialize() async {}

  @override
  Future<PackageSourceDescriptor?> findByCommonId(String commonId) async {
    for (final descriptor in descriptors) {
      if (descriptor.commonIds.contains(commonId)) return descriptor;
    }
    return null;
  }

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async {
    for (final descriptor in descriptors) {
      if (descriptor.desktopId == desktopId) return descriptor;
    }
    return null;
  }

  @override
  Future<PackageSourceDescriptor?> findByAlias(String alias) async {
    for (final descriptor in descriptors) {
      if (descriptor.aliases.contains(alias)) return descriptor;
    }
    return null;
  }

  @override
  Future<PackageSourceDescriptor?> findByPackageName(String packageName) async {
    for (final descriptor in descriptors) {
      if (descriptor.packageName == packageName) return descriptor;
    }
    return null;
  }

  @override
  Future<PackageRuntimeState> getRuntimeState(String packageId) async {
    return const PackageRuntimeState(isInstalled: false);
  }
}

void main() {
  tearDown(resetAllServices);

  test(
    'resolves a matching snap descriptor using the common-id tier',
    () async {
      const source = PackageSourceDescriptor(
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
        commonIds: ['org.videolan.vlc'],
        desktopId: 'vlc_vlc.desktop',
        packageName: 'vlc',
        isDesktopApplication: true,
      );

      final service = PackageMappingService(
        adapters: [
          _FakeAdapter(PackageFormat.deb, [source]),
          _FakeAdapter(PackageFormat.snap, [snap]),
        ],
      );

      final identity = await service.resolve(source);

      expect(identity, isNotNull);
      expect(identity!.unifiedId, 'org.videolan.vlc');
      expect(identity.sources.length, 2);
      expect(identity.hasFormat(PackageFormat.snap), isTrue);
    },
  );

  test('looks up each common ID and resolves a later match', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonIds: ['org.example.legacy', 'org.videolan.vlc'],
    );
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
    );

    final identity = await PackageMappingService(
      adapters: [
        _FakeAdapter(PackageFormat.snap, [source]),
        _FakeAdapter(PackageFormat.deb, [deb]),
      ],
    ).resolve(source);

    expect(identity, isNotNull);
    expect(identity!.appStreamId, 'org.videolan.vlc');
  });

  test('falls back to desktop ID after common ID lookups miss', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
      desktopId: 'vlc.desktop',
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonIds: ['org.example.vlc'],
      desktopId: 'vlc.desktop',
    );

    final identity = await PackageMappingService(
      adapters: [
        _FakeAdapter(PackageFormat.deb, [source]),
        _FakeAdapter(PackageFormat.snap, [snap]),
      ],
    ).resolve(source);

    expect(identity, isNotNull);
    expect(identity!.sources, [source, snap]);
  });

  test('falls back to AppStream aliases after stronger tiers miss', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'gimp',
      commonIds: ['gimp.desktop'],
      desktopId: 'gimp_gimp.desktop',
    );
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'gimp',
      commonIds: ['org.gimp.gimp'],
      desktopId: 'org.gimp.gimp.desktop',
      aliases: ['gimp.desktop'],
    );

    final identity = await PackageMappingService(
      adapters: [
        _FakeAdapter(PackageFormat.snap, [source]),
        _FakeAdapter(PackageFormat.deb, [deb]),
      ],
    ).resolve(source);

    expect(identity, isNotNull);
    expect(identity!.sources, [deb, source]);
  });

  test('returns null when no cross-format match is available', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'firefox',
      commonIds: ['org.mozilla.firefox'],
      desktopId: 'firefox.desktop',
      packageName: 'firefox',
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'chromium',
      commonIds: ['org.chromium.chromium'],
      desktopId: 'chromium.desktop',
      packageName: 'chromium',
      isDesktopApplication: true,
    );

    final service = PackageMappingService(
      adapters: [
        _FakeAdapter(PackageFormat.deb, [source]),
        _FakeAdapter(PackageFormat.snap, [snap]),
      ],
    );

    expect(await service.resolve(source), isNull);
  });

  test(
    'provider keeps a stable service instance and resolves identities',
    () async {
      const source = PackageSourceDescriptor(
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
        commonIds: ['org.videolan.vlc'],
        desktopId: 'vlc_vlc.desktop',
        packageName: 'vlc',
        isDesktopApplication: true,
      );
      final service = PackageMappingService(
        adapters: [
          _FakeAdapter(PackageFormat.deb, [source]),
          _FakeAdapter(PackageFormat.snap, [snap]),
        ],
      );

      final container = createContainer(
        overrides: [
          packageMappingServiceProvider.overrideWithValue(service),
        ],
      );

      final first = container.read(packageMappingServiceProvider);
      final second = container.read(packageMappingServiceProvider);
      final identity1 = await container.read(
        unifiedIdentityProvider(source).future,
      );
      final identity2 = await container.read(
        unifiedIdentityProvider(source).future,
      );

      expect(identical(first, second), isTrue);
      expect(identity1, isNotNull);
      expect(identity2, isNotNull);
      expect(identity1!.unifiedId, identity2!.unifiedId);
      expect(identity1.unifiedId, 'org.videolan.vlc');
    },
  );

  test('provider propagates service errors', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
      desktopId: 'vlc.desktop',
      packageName: 'vlc',
      isDesktopApplication: true,
    );
    final container = createContainer(
      overrides: [
        packageMappingServiceProvider.overrideWithValue(
          _ThrowingPackageMappingService(),
        ),
      ],
    );

    expect(
      () => container.read(unifiedIdentityProvider(source).future),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'runtime state service merges package sources for a unified identity',
    () async {
      const sourceDeb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'firefox',
        commonIds: ['org.mozilla.firefox'],
        desktopId: 'firefox.desktop',
        packageName: 'firefox',
        isDesktopApplication: true,
      );
      const sourceSnap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'firefox',
        commonIds: ['org.mozilla.firefox'],
        desktopId: 'firefox_firefox.desktop',
        packageName: 'firefox',
        isDesktopApplication: true,
      );
      const debState = PackageRuntimeState(
        isInstalled: true,
        installedVersion: '120.0',
      );
      const snapState = PackageRuntimeState(
        isInstalled: true,
        installedVersion: '120.0',
        channelOrOrigin: 'latest/stable',
      );

      final identity = UnifiedAppIdentity(
        unifiedId: 'org.mozilla.firefox',
        appStreamId: 'org.mozilla.firefox',
        sources: [sourceDeb, sourceSnap],
      );

      final service = PackageRuntimeStateService(
        adapters: [
          _RuntimeAdapter(PackageFormat.deb, debState),
          _RuntimeAdapter(PackageFormat.snap, snapState),
        ],
      );

      final states = await service.getIdentityState(identity);

      expect(states[PackageFormat.deb], debState);
      expect(states[PackageFormat.snap], snapState);
    },
  );

  test('runtime state provider queries again on explicit refresh', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'firefox',
    );
    const initialState = PackageRuntimeState(isInstalled: false);
    const installedState = PackageRuntimeState(
      isInstalled: true,
      installedVersion: '120.0',
    );
    final adapter = _RuntimeAdapter(PackageFormat.deb, initialState);
    final service = PackageRuntimeStateService(adapters: [adapter]);
    final identity = UnifiedAppIdentity(
      unifiedId: 'firefox',
      appStreamId: 'firefox',
      sources: [source],
    );

    final container = createContainer(
      overrides: [
        packageRuntimeStateServiceProvider.overrideWithValue(service),
      ],
    );
    final provider = runtimeStateProvider(identity);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    expect(await container.read(provider.future), {
      PackageFormat.deb: initialState,
    });
    adapter.state = installedState;
    expect(await container.read(provider.future), {
      PackageFormat.deb: initialState,
    });
    expect(await container.refresh(provider.future), {
      PackageFormat.deb: installedState,
    });
  });

  test(
    'runtime state service returns an empty snapshot for no sources',
    () async {
      final service = PackageRuntimeStateService(adapters: []);
      const identity = UnifiedAppIdentity(
        unifiedId: 'firefox',
        appStreamId: 'firefox',
        sources: [],
      );
      expect(await service.getIdentityState(identity), isEmpty);
    },
  );

  test('runtime state provider propagates adapter errors', () async {
    final adapter = _RuntimeAdapter(
      PackageFormat.deb,
      const PackageRuntimeState(isInstalled: false),
    )..error = StateError('query failed');
    final container = createContainer(
      overrides: [
        packageRuntimeStateServiceProvider.overrideWithValue(
          PackageRuntimeStateService(adapters: [adapter]),
        ),
      ],
    );
    const identity = UnifiedAppIdentity(
      unifiedId: 'firefox',
      appStreamId: 'firefox',
      sources: [
        PackageSourceDescriptor(
          format: PackageFormat.deb,
          packageId: 'firefox',
        ),
      ],
    );
    await expectLater(
      container.read(runtimeStateProvider(identity).future),
      throwsA(isA<StateError>()),
    );
  });
}

class _RuntimeAdapter implements PackageFormatAdapter {
  _RuntimeAdapter(this.format, this.state);

  @override
  final PackageFormat format;

  PackageRuntimeState state;
  Object? error;

  @override
  Future<void> initialize() async {}

  @override
  Future<PackageSourceDescriptor?> findByCommonId(String commonId) async =>
      null;

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async =>
      null;

  @override
  Future<PackageSourceDescriptor?> findByAlias(String alias) async => null;

  @override
  Future<PackageSourceDescriptor?> findByPackageName(
    String packageName,
  ) async => null;

  @override
  Future<PackageRuntimeState> getRuntimeState(String packageId) async {
    if (error != null) throw error!;
    return state;
  }
}

class _ThrowingPackageMappingService extends PackageMappingService {
  _ThrowingPackageMappingService()
    : super(
        adapters: const [],
      );

  @override
  Future<UnifiedAppIdentity?> resolve(PackageSourceDescriptor source) async {
    throw StateError('mapping failed');
  }
}
