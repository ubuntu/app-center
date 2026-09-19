import 'package:app_center/mapping/mapping.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    return descriptors.firstWhere(
      (descriptor) => descriptor.commonId == commonId,
      orElse: () => const PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: '',
      ),
    );
  }

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async {
    return descriptors.firstWhere(
      (descriptor) => descriptor.desktopId == desktopId,
      orElse: () => const PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: '',
      ),
    );
  }

  @override
  Future<PackageSourceDescriptor?> findByPackageName(String packageName) async {
    return descriptors.firstWhere(
      (descriptor) => descriptor.packageName == packageName,
      orElse: () => const PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: '',
      ),
    );
  }

  @override
  Stream<PackageRuntimeState> watchRuntimeState(String packageId) async* {
    yield const PackageRuntimeState(isInstalled: false);
  }
}

void main() {
  test(
    'resolves a matching snap descriptor using the common-id tier',
    () async {
      const source = PackageSourceDescriptor(
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
        commonId: 'org.videolan.vlc',
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

  test('returns null when no cross-format match is available', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'firefox',
      commonId: 'org.mozilla.firefox',
      desktopId: 'firefox.desktop',
      packageName: 'firefox',
      isDesktopApplication: true,
    );
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'chromium',
      commonId: 'org.chromium.chromium',
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
        commonId: 'org.videolan.vlc',
        desktopId: 'vlc.desktop',
        packageName: 'vlc',
        isDesktopApplication: true,
      );
      const snap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'vlc',
        commonId: 'org.videolan.vlc',
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
      commonId: 'org.videolan.vlc',
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
