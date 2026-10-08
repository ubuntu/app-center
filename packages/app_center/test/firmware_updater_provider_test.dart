import 'package:app_center/addons/addons.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  Future<AsyncValue<SnapLauncher?>> readLauncher({
    bool isLaunchable = false,
  }) async {
    final container = createContainer(
      overrides: [
        launchProvider.overrideWith(
          (ref, snap) => createMockSnapLauncher(isLaunchable: isLaunchable),
        ),
      ],
    );
    container.listen(firmwareUpdaterLauncherProvider, (_, _) {});
    await settle();
    return container.read(firmwareUpdaterLauncherProvider);
  }

  test('not installed', () async {
    final service = registerMockSnapdService();
    when(service.getSnap(kFirmwareUpdaterSnapName)).thenThrow(
      SnapdException(message: 'not installed', kind: 'snap-not-found'),
    );

    final value = await readLauncher(isLaunchable: true);
    expect(value.hasError, isFalse);
    expect(value.value, isNull);
  });

  test('other snapd errors', () async {
    final service = registerMockSnapdService();
    when(service.getSnap(kFirmwareUpdaterSnapName)).thenThrow(
      SnapdException(message: 'offline', kind: 'network-timeout'),
    );

    final value = await readLauncher(isLaunchable: true);
    expect(value.error, isA<SnapdException>());
    expect(value.valueOrNull, isNull);
  });

  test('installed but not launchable', () async {
    registerMockSnapdService(
      localSnap: createSnap(name: kFirmwareUpdaterSnapName),
    );

    final value = await readLauncher();
    expect(value.hasError, isFalse);
    expect(value.value, isNull);
  });

  test('installed and launchable', () async {
    registerMockSnapdService(
      localSnap: createSnap(name: kFirmwareUpdaterSnapName),
    );

    final value = await readLauncher(isLaunchable: true);
    expect(value.value?.isLaunchable, isTrue);
  });
}
