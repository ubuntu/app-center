import 'dart:async';

import 'package:app_center/media_support/media_support.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

const _addons = 'ubuntu-restricted-addons';
const _aac = 'gstreamer1.0-fdkaac';

PackageKitPackageEvent _event(String name, PackageKitInfo info) =>
    PackageKitPackageEvent(
      packageId: PackageKitPackageId(name: name, version: '1.0'),
      info: info,
      summary: name,
    );

void main() {
  tearDown(resetAllServices);

  test('sums details sizes and installs only missing packages', () async {
    final addons = _event(_addons, PackageKitInfo.installed);
    final aac = _event(_aac, PackageKitInfo.available);
    final kit = createMockPackageKitService(
      resolveMap: {_addons: addons, _aac: aac},
      availableUpdates: [_event(_addons, PackageKitInfo.normal)],
      packageDetailsMany: {
        _addons: PackageKitDetailsEvent(
          packageId: addons.packageId,
          size: 1000,
        ),
        _aac: PackageKitDetailsEvent(packageId: aac.packageId, size: 2000),
      },
    );
    final container = createContainer();
    final data = await container.read(mediaSupportModelProvider.future);
    expect(data.size, 3000);
    expect(data.isInstalled, isFalse);
    expect(data.missingIds.map((p) => p.name), [_aac]);
    await container.read(mediaSupportModelProvider.notifier).install();
    final ids =
        verify(kit.installAll(captureAny)).captured.single
            as Iterable<PackageKitPackageId>;
    expect(ids.map((p) => p.name), [_aac]);
    verifyNever(kit.updateAllPackages(any));
  });

  test('uninstall removes both installed packages', () async {
    final kit = createMockPackageKitService(
      resolveMap: {
        _addons: _event(_addons, PackageKitInfo.installed),
        _aac: _event(_aac, PackageKitInfo.installed),
      },
    );
    final container = createContainer();
    expect(
      (await container.read(mediaSupportModelProvider.future)).isInstalled,
      isTrue,
    );
    await container.read(mediaSupportModelProvider.notifier).uninstall();
    final ids =
        verify(kit.removeAll(captureAny)).captured.single
            as Iterable<PackageKitPackageId>;
    expect(ids.map((p) => p.name), [_addons, _aac]);
  });

  test('updates only packages with available updates', () async {
    final kit = createMockPackageKitService(
      resolveMap: {
        _addons: _event(_addons, PackageKitInfo.installed),
        _aac: _event(_aac, PackageKitInfo.installed),
      },
      availableUpdates: [
        _event(_aac, PackageKitInfo.normal),
        _event('unrelated', PackageKitInfo.normal),
      ],
    );
    final container = createContainer();
    await container.read(mediaSupportModelProvider.future);
    await container.read(mediaSupportModelProvider.notifier).updatePackages();
    final ids =
        verify(kit.updateAllPackages(captureAny)).captured.single
            as Iterable<PackageKitPackageId>;
    expect(ids.map((p) => p.name), [_aac]);
  });

  test(
    'cancel waits for transaction to exit without reporting an error',
    () async {
      final kit = createMockPackageKitService(transactionId: 7);
      final pending = Completer<void>();
      when(kit.waitTransaction(7)).thenAnswer((_) => pending.future);
      final container = createContainer();
      await container.read(mediaSupportModelProvider.future);
      final model = container.read(mediaSupportModelProvider.notifier);
      final action = model.install();
      await pumpEventQueue();
      expect(
        container.read(mediaSupportModelProvider).value!.activeTransactionId,
        7,
      );
      await model.cancel();
      verify(kit.cancelTransaction(7)).called(1);
      pending.completeError(
        PackageKitTransactionError('cancelled', exit: PackageKitExit.cancelled),
      );
      await action;
      expect(
        container.read(mediaSupportModelProvider).value!.hasError,
        isFalse,
      );
    },
  );

  test('failure shows error and retry repeats the failed action', () async {
    final kit = createMockPackageKitService(transactionId: 3);
    when(kit.waitTransaction(3)).thenThrow(
      PackageKitTransactionError('failed', exit: PackageKitExit.failed),
    );
    final container = createContainer();
    await container.read(mediaSupportModelProvider.future);
    final model = container.read(mediaSupportModelProvider.notifier);
    await model.install();
    expect(container.read(mediaSupportModelProvider).value!.hasError, isTrue);
    when(kit.waitTransaction(3)).thenAnswer((_) async {});
    await model.retry();
    verify(kit.installAll(any)).called(2);
    expect(container.read(mediaSupportModelProvider).value!.hasError, isFalse);
  });
}
