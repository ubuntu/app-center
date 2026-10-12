import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/mapping/mapping.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/snapd/snap_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

class _FakeAdapter implements PackageFormatAdapter {
  _FakeAdapter(this.format, this.descriptors, {this.fail = false});

  @override
  final PackageFormat format;
  final List<PackageSourceDescriptor> descriptors;
  final bool fail;

  PackageSourceDescriptor? _find(bool Function(PackageSourceDescriptor) test) {
    if (fail) throw Exception('lookup failed');
    for (final descriptor in descriptors) {
      if (test(descriptor)) return descriptor;
    }
    return null;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<PackageSourceDescriptor?> findByCommonId(String commonId) async =>
      _find((d) => d.commonIds.contains(commonId));

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async =>
      _find((d) => d.desktopId == desktopId);

  @override
  Future<PackageSourceDescriptor?> findByAlias(String alias) async =>
      _find((d) => d.aliases.contains(alias));

  @override
  Future<PackageSourceDescriptor?> findByPackageName(String name) async =>
      _find((d) => d.packageName == name);

  @override
  Future<PackageRuntimeState> getRuntimeState(String packageId) async =>
      const PackageRuntimeState(isInstalled: false);
}

const _snapDescriptor = PackageSourceDescriptor(
  format: PackageFormat.snap,
  packageId: 'testsnap',
  packageName: 'testsnap',
  commonIds: ['org.test.app'],
  isDesktopApplication: true,
);

const _debDescriptor = PackageSourceDescriptor(
  format: PackageFormat.deb,
  packageId: 'test-app',
  packageName: 'test-app',
  commonIds: ['org.test.app'],
  isDesktopApplication: true,
);

AppDetailsIdentityResolver _resolver({
  List<PackageSourceDescriptor> snaps = const [_snapDescriptor],
  List<PackageSourceDescriptor> debs = const [_debDescriptor],
  bool snapFails = false,
  bool debFails = false,
}) {
  final snapAdapter = _FakeAdapter(
    PackageFormat.snap,
    snaps,
    fail: snapFails,
  );
  final debAdapter = _FakeAdapter(PackageFormat.deb, debs, fail: debFails);
  return AppDetailsIdentityResolver(
    snapAdapter: snapAdapter,
    debAdapter: debAdapter,
    mappingService: PackageMappingService(adapters: [snapAdapter, debAdapter]),
  );
}

void main() {
  tearDown(resetAllServices);

  group('entry', () {
    test('converts legacy data to typed references', () {
      final snapData = SnapData(
        name: 'testsnap',
        localSnap: null,
        storeSnap: createSnap(name: 'testsnap'),
      );
      final subscription = const Stream<PackageKitServiceError>.empty().listen(
        null,
      );
      addTearDown(subscription.cancel);
      final debData = DebData(
        id: 'org.test.app',
        component: createAppstreamComponent(id: 'org.test.app'),
        hasUpdate: false,
        errorStream: subscription,
      );

      expect(
        AppDetailsEntry.fromSnapData(snapData),
        const AppDetailsEntry.snap('testsnap'),
      );
      expect(
        AppDetailsEntry.fromDebData(debData),
        const AppDetailsEntry.debComponent('org.test.app'),
      );
    });

    test('rejects empty identifiers', () async {
      expect(const AppDetailsEntry.snap(' ').isValid, isFalse);
      expect(const AppDetailsEntry.debComponent('').isValid, isFalse);
      expect(
        const AppDetailsEntry.identity(
          UnifiedAppIdentity(
            unifiedId: 'x',
            appStreamId: 'x',
            sources: [
              PackageSourceDescriptor(
                format: PackageFormat.deb,
                packageId: 'x',
              ),
            ],
          ),
        ).isValid,
        isFalse,
      );
      await expectLater(
        _resolver().resolve(const AppDetailsEntry.snap('')),
        throwsA(isA<InvalidAppDetailsEntry>()),
      );
    });
  });

  group('source key', () {
    test('uses each backend namespace', () {
      expect(SourceKey.fromDescriptor(_snapDescriptor), testSnapKey);
      expect(SourceKey.fromDescriptor(_debDescriptor), testDebKey);
      expect(
        SourceKey.fromDescriptor(
          const PackageSourceDescriptor(
            format: PackageFormat.deb,
            packageId: 'test-app',
          ),
        ),
        isNull,
      );
    });
  });

  group('resolution', () {
    test('snap entry finds its deb counterpart', () async {
      final resolved = await _resolver().resolve(
        const AppDetailsEntry.snap('testsnap'),
      );
      expect(resolved.discoveryFailed, isFalse);
      expect(resolved.sourceKeys, [testSnapKey, testDebKey]);
    });

    test(
      'entries from either format deduplicate to the same sources',
      () async {
        final resolver = _resolver();
        final fromSnap = await resolver.resolve(
          const AppDetailsEntry.snap('testsnap'),
        );
        final fromDeb = await resolver.resolve(
          const AppDetailsEntry.debComponent('org.test.app'),
        );
        expect(fromSnap.sourceKeys, fromDeb.sourceKeys);
        expect(fromSnap.identity.unifiedId, fromDeb.identity.unifiedId);
      },
    );

    test('identity entries are used as given', () async {
      final identity = createResolvedIdentity().identity;
      final resolved = await _resolver().resolve(
        AppDetailsEntry.identity(identity),
      );
      expect(resolved.identity, identity);
    });

    test('confirmed no-match yields a deterministic single source', () async {
      final resolver = _resolver(debs: const []);
      final first = await resolver.resolve(
        const AppDetailsEntry.snap('testsnap'),
      );
      final second = await resolver.resolve(
        const AppDetailsEntry.snap('testsnap'),
      );
      expect(first.discoveryFailed, isFalse);
      expect(first.sourceKeys, [testSnapKey]);
      expect(first.identity, second.identity);
      expect(first.identity.appStreamId, 'org.test.app');
    });

    test('unknown snap falls back to the typed name', () async {
      final resolved = await _resolver(snaps: const []).resolve(
        const AppDetailsEntry.snap('local-only'),
      );
      expect(resolved.sourceKeys, [
        const SourceKey(format: PackageFormat.snap, id: 'local-only'),
      ]);
    });

    test('lookup failure is not a confirmed no-match', () async {
      final resolved = await _resolver(snapFails: true).resolve(
        const AppDetailsEntry.snap('testsnap'),
      );
      expect(resolved.discoveryFailed, isTrue);
      expect(resolved.sourceKeys, [testSnapKey]);
    });

    test('counterpart lookup failure keeps the known source', () async {
      final resolved = await _resolver(debFails: true).resolve(
        const AppDetailsEntry.snap('testsnap'),
      );
      expect(resolved.discoveryFailed, isTrue);
      expect(resolved.sourceKeys, [testSnapKey]);
    });

    test('deb entry keeps its component ID as key', () async {
      final resolved = await _resolver(
        debs: [
          _debDescriptor.copyWith(commonIds: ['org.test.other']),
        ],
        snaps: const [],
      ).resolve(const AppDetailsEntry.debComponent('org.test.other'));
      expect(resolved.sourceKeys, [
        const SourceKey(format: PackageFormat.deb, id: 'org.test.other'),
      ]);
    });
  });

  test('provider resolves through the injected resolver', () async {
    final container = createContainer(
      overrides: [
        appDetailsIdentityResolverProvider.overrideWithValue(_resolver()),
      ],
    );
    final resolved = await container.read(
      appDetailsIdentityProvider(const AppDetailsEntry.snap('testsnap')).future,
    );
    expect(resolved.sourceKeys, [testSnapKey, testDebKey]);
  });
}
