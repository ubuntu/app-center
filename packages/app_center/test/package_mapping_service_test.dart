import 'package:app_center/mapping/mapping.dart';
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

  test(
    'runtime state service merges package sources for a unified identity',
    () async {
      const sourceDeb = PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'firefox',
        commonId: 'org.mozilla.firefox',
        desktopId: 'firefox.desktop',
        packageName: 'firefox',
        isDesktopApplication: true,
      );
      const sourceSnap = PackageSourceDescriptor(
        format: PackageFormat.snap,
        packageId: 'firefox',
        commonId: 'org.mozilla.firefox',
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
          _StreamingRuntimeAdapter(PackageFormat.deb, [debState]),
          _StreamingRuntimeAdapter(PackageFormat.snap, [snapState]),
        ],
      );

      final states = await service
          .watchIdentity(identity)
          .where((snapshot) => snapshot.length == 2)
          .first;

      expect(states[PackageFormat.deb], debState);
      expect(states[PackageFormat.snap], snapState);
    },
  );

  test('runtime state service cancels adapter subscriptions', () async {
    const source = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'firefox',
    );
    final adapter = _CancelableRuntimeAdapter();
    final service = PackageRuntimeStateService(adapters: [adapter]);
    final identity = UnifiedAppIdentity(
      unifiedId: 'firefox',
      appStreamId: 'firefox',
      sources: [source],
    );

    final subscription = service.watchIdentity(identity).listen((_) {});
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(adapter.cancelled, isTrue);
  });
}

class _StreamingRuntimeAdapter implements PackageFormatAdapter {
  _StreamingRuntimeAdapter(this.format, this.states);

  @override
  final PackageFormat format;

  final List<PackageRuntimeState> states;

  @override
  Future<void> initialize() async {}

  @override
  Future<PackageSourceDescriptor?> findByCommonId(String commonId) async =>
      null;

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async =>
      null;

  @override
  Future<PackageSourceDescriptor?> findByPackageName(
    String packageName,
  ) async => null;

  @override
  Stream<PackageRuntimeState> watchRuntimeState(String packageId) async* {
    yield* Stream.fromIterable(states);
  }
}

class _CancelableRuntimeAdapter implements PackageFormatAdapter {
  @override
  PackageFormat get format => PackageFormat.deb;

  bool cancelled = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<PackageSourceDescriptor?> findByCommonId(String commonId) async =>
      null;

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async =>
      null;

  @override
  Future<PackageSourceDescriptor?> findByPackageName(
    String packageName,
  ) async => null;

  @override
  Stream<PackageRuntimeState> watchRuntimeState(String packageId) {
    return Stream.multi((controller) {
      controller.add(const PackageRuntimeState(isInstalled: false));
      controller.onCancel = () {
        cancelled = true;
      };
    });
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
