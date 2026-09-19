import 'package:app_center/appstream/appstream_service.dart';
import 'package:app_center/mapping/mapping.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:app_center/snapd/snapd_service.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'package_adapters_test.mocks.dart';

@GenerateMocks([AppstreamPool, PackageKitService, SnapdService])
void main() {
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
        commonId: 'org.videolan.vlc',
        desktopId: 'vlc.desktop',
        packageName: 'vlc',
        aliases: ['vlc-legacy.desktop'],
        isDesktopApplication: true,
      ),
    );
  });

  test('Snap adapter uses the common-id find query', () async {
    final snapd = MockSnapdService();
    final snap = createSnap(
      name: 'vlc',
      commonIds: ['org.videolan.vlc'],
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
    expect(descriptor?.commonId, 'org.videolan.vlc');
    expect(descriptor?.desktopId, 'vlc_vlc.desktop');
    expect(descriptor?.isDesktopApplication, isTrue);
    verify(
      snapd.find(
        commonId: 'org.videolan.vlc',
        scope: SnapFindScope.wide,
      ),
    ).called(1);
  });
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
