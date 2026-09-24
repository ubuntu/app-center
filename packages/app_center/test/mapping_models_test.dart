import 'package:app_center/mapping/mapping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('package formats expose display names', () {
    expect(PackageFormat.snap.displayName, 'Snap');
    expect(PackageFormat.deb.displayName, 'Debian (APT)');
  });

  test('source descriptors are value objects', () {
    const first = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
      desktopId: 'vlc_vlc.desktop',
      packageName: 'vlc',
    );
    const second = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
      commonIds: ['org.videolan.vlc'],
      desktopId: 'vlc_vlc.desktop',
      packageName: 'vlc',
    );

    expect(first, second);
    expect(first.copyWith(packageName: null).packageName, isNull);
  });

  test('identity finds sources by format', () {
    const snap = PackageSourceDescriptor(
      format: PackageFormat.snap,
      packageId: 'vlc',
    );
    const deb = PackageSourceDescriptor(
      format: PackageFormat.deb,
      packageId: 'vlc',
    );
    const identity = UnifiedAppIdentity(
      unifiedId: 'org.videolan.vlc',
      appStreamId: 'org.videolan.vlc',
      sources: [snap, deb],
    );

    expect(identity.hasFormat(PackageFormat.snap), isTrue);
    expect(identity.hasFormat(PackageFormat.deb), isTrue);
    expect(identity.getSource(PackageFormat.snap), snap);
    expect(identity.getSource(PackageFormat.deb), deb);
  });

  test('runtime state is independent from identity data', () {
    const identity = UnifiedAppIdentity(
      unifiedId: 'org.videolan.vlc',
      appStreamId: 'org.videolan.vlc',
      sources: [
        PackageSourceDescriptor(
          format: PackageFormat.snap,
          packageId: 'vlc',
        ),
      ],
    );
    const installed = PackageRuntimeState(
      isInstalled: true,
      installedVersion: '3.0.21',
      channelOrOrigin: 'latest/stable',
    );

    expect(identity.unifiedId, 'org.videolan.vlc');
    expect(installed.isInstalled, isTrue);
    expect(installed.installedVersion, '3.0.21');
    expect(installed.hasUpdate, isFalse);
    expect(installed.isBusy, isFalse);
  });
}
