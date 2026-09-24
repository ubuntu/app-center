import 'package:app_center/appstream/appstream_service.dart';
import 'package:app_center/mapping/mapping.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:app_center/snapd/snapd_service.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'package_adapters_test.mocks.dart';

@GenerateMocks([AppstreamPool, PackageKitService, SnapdService])
void main() {
  tearDown(resetAllServices);

  test('Deb adapter queries current runtime state on each request', () async {
    final packageKit = MockPackageKitService();
    const installed = PackageKitPackageEvent(
      info: PackageKitInfo.installed,
      packageId: PackageKitPackageId(name: 'vlc', version: '3.0'),
      summary: 'VLC',
    );
    const update = PackageKitPackageEvent(
      info: PackageKitInfo.available,
      packageId: PackageKitPackageId(name: 'vlc', version: '3.1'),
      summary: 'VLC',
    );
    when(packageKit.activateService()).thenAnswer((_) async {});
    when(
      packageKit.resolve(['vlc']),
    ).thenAnswer((_) async => {'vlc': installed});
    when(packageKit.getUpdates()).thenAnswer((_) async => [update]);
    final adapter = DebPackageAdapter(
      appstream: AppstreamService(pool: MockAppstreamPool()),
      packageKit: packageKit,
    );

    expect(
      await adapter.getRuntimeState('vlc'),
      const PackageRuntimeState(
        isInstalled: true,
        installedVersion: '3.0',
        availableVersion: '3.1',
        hasUpdate: true,
      ),
    );

    when(packageKit.resolve(['vlc'])).thenAnswer((_) async => {'vlc': null});
    when(packageKit.getUpdates()).thenAnswer((_) async => []);
    expect(
      await adapter.getRuntimeState('vlc'),
      const PackageRuntimeState(isInstalled: false),
    );
  });

  test('Snap adapter queries runtime state on demand', () async {
    final snapd = MockSnapdService();
    final snap = createSnap(name: 'vlc', commonIds: [], apps: []);
    when(snapd.getSnap('vlc')).thenAnswer((_) async => snap);

    final state = await SnapPackageAdapter(snapd: snapd).getRuntimeState('vlc');

    expect(state.isInstalled, isTrue);
    expect(state.installedVersion, snap.version);
    expect(state.channelOrOrigin, snap.trackingChannel);
    expect(state.isBusy, isFalse);
  });

  test('Deb adapter converts AppStream metadata to a descriptor', () async {
    final pool = MockAppstreamPool();
    final component = const AppstreamComponent(
      id: 'org.videolan.vlc',
      type: AppstreamComponentType.desktopApplication,
      package: 'vlc',
      name: {'C': 'VLC'},
      summary: {},
      launchables: [AppstreamLaunchableDesktopId('vlc.desktop')],
      provides: [AppstreamProvidesId('vlc-legacy.desktop')],
    );
    when(pool.components).thenReturn([component]);
    when(pool.load()).thenAnswer((_) async {});

    final adapter = DebPackageAdapter(
      appstream: AppstreamService(pool: pool),
      packageKit: MockPackageKitService(),
    );

    final descriptor = await adapter.findByCommonId('ORG.VIDEOLAN.VLC');

    expect(
      descriptor,
      const PackageSourceDescriptor(
        format: PackageFormat.deb,
        packageId: 'vlc',
        commonIds: ['org.videolan.vlc'],
        desktopId: 'vlc.desktop',
        packageName: 'vlc',
        aliases: ['vlc-legacy.desktop'],
        isDesktopApplication: true,
      ),
    );

    expect(
      await adapter.findByAlias(' VLC-LEGACY.DESKTOP '),
      descriptor,
    );
  });

  test('Snap adapter uses the common-id find query', () async {
    final snapd = MockSnapdService();
    final snap = createSnap(
      name: 'vlc',
      commonIds: ['org.videolan.vlc', 'org.videolan.vlc-legacy'],
      apps: [
        const SnapApp(
          name: 'vlc',
          commonId: 'org.videolan.vlc',
          desktopFile: 'vlc_vlc.desktop',
        ),
      ],
    );
    when(
      snapd.find(
        commonId: anyNamed('commonId'),
        scope: anyNamed('scope'),
      ),
    ).thenAnswer((_) async => [snap]);

    final adapter = SnapPackageAdapter(snapd: snapd);
    final descriptor = await adapter.findByCommonId('org.videolan.vlc');

    expect(descriptor?.format, PackageFormat.snap);
    expect(descriptor?.packageId, 'vlc');
    expect(
      descriptor?.commonIds,
      ['org.videolan.vlc', 'org.videolan.vlc-legacy'],
    );
    expect(descriptor?.desktopId, 'vlc_vlc.desktop');
    expect(descriptor?.isDesktopApplication, isTrue);
    verify(
      snapd.find(
        commonId: 'org.videolan.vlc',
        scope: SnapFindScope.wide,
      ),
    ).called(1);
  });

  test(
    'Snap adapter matches desktop IDs after stripping the Snap prefix',
    () async {
      final snapd = MockSnapdService();
      final snap = createSnap(
        name: 'vlc',
        commonIds: [],
        apps: [
          const SnapApp(name: 'vlc', desktopFile: 'vlc_vlc.desktop'),
        ],
      );
      when(
        snapd.find(
          query: anyNamed('query'),
          scope: anyNamed('scope'),
        ),
      ).thenAnswer((_) async => [snap]);

      final descriptor = await SnapPackageAdapter(
        snapd: snapd,
      ).findByDesktopId('vlc.desktop');

      expect(descriptor?.packageId, 'vlc');
      verify(
        snapd.find(query: 'vlc.desktop', scope: SnapFindScope.wide),
      ).called(1);
    },
  );
}

Snap createSnap({
  required String name,
  required List<String> commonIds,
  required List<SnapApp> apps,
}) => Snap(
  id: '',
  name: name,
  revision: 0,
  version: '',
  channel: '',
  type: '',
  apps: apps,
  commonIds: commonIds,
  confinement: SnapConfinement.strict,
);
