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

  test('includes dependencies and installs only missing packages', () async {
    final addons = _event(_addons, PackageKitInfo.installed);
    final aac = _event(_aac, PackageKitInfo.available);
    final dependency = _event('codec-library', PackageKitInfo.installing);
    final kit = createMockPackageKitService(
      resolveMap: {_addons: addons, _aac: aac},
      availableUpdates: [_event(_addons, PackageKitInfo.normal)],
      simulatedInstall: [aac, dependency, dependency],
      packageDetailsMany: {
        _addons: PackageKitDetailsEvent(
          packageId: addons.packageId,
          size: 1000,
        ),
        _aac: PackageKitDetailsEvent(packageId: aac.packageId, size: 2000),
        'codec-library': PackageKitDetailsEvent(
          packageId: dependency.packageId,
          size: 10000000,
        ),
      },
    );
    final container = createContainer();
    final data = await container.read(mediaSupportModelProvider.future);
    expect(data.size, 10002000);
    verify(kit.simulateInstall([aac.packageId])).called(1);
    verify(kit.getDetails([aac.packageId, dependency.packageId])).called(1);
    expect(data.isInstalled, isFalse);
    expect(data.missingIds.map((p) => p.name), [_aac]);
    await container.read(mediaSupportModelProvider.notifier).install();
    final ids =
        verify(kit.installAll(captureAny)).captured.single
            as Iterable<PackageKitPackageId>;
    expect(ids.map((p) => p.name), [_aac]);
    verifyNever(kit.updateAllPackages(any));
  });

  test('falls back to package sizes when simulation fails', () async {
    final addons = _event(_addons, PackageKitInfo.available);
    final kit = createMockPackageKitService(
      resolveMap: {_addons: addons},
      packageDetailsMany: {
        _addons: PackageKitDetailsEvent(
          packageId: addons.packageId,
          size: 1000,
        ),
      },
    );
    when(kit.simulateInstall(any)).thenThrow(
      PackageKitTransactionError('simulation unsupported'),
    );
    final container = createContainer();
    final data = await container.read(mediaSupportModelProvider.future);
    expect(data.size, 1000);
    expect(data.hasError, isFalse);
  });

  test('size failures do not prevent installation', () async {
    final kit = createMockPackageKitService(
      resolveMap: {_addons: _event(_addons, PackageKitInfo.available)},
    );
    when(kit.simulateInstall(any)).thenThrow(Exception('simulation failed'));
    when(kit.getDetails(any)).thenThrow(Exception('details failed'));
    final container = createContainer();
    expect(
      (await container.read(mediaSupportModelProvider.future)).size,
      isNull,
    );
    await container.read(mediaSupportModelProvider.notifier).install();
    verify(kit.installAll(any)).called(1);
  });

  test('counts both architectures of a dependency', () async {
    final dependencies = [
      for (final arch in ['amd64', 'i386'])
        PackageKitPackageEvent(
          packageId: PackageKitPackageId(
            name: 'codec-library',
            version: '1.0',
            arch: arch,
          ),
          info: PackageKitInfo.installing,
          summary: 'codec-library',
        ),
    ];
    final kit = createMockPackageKitService(simulatedInstall: dependencies);
    when(kit.getDetails(any)).thenAnswer((invocation) async {
      final ids =
          invocation.positionalArguments.first as List<PackageKitPackageId>;
      return {
        for (final id in ids)
          id.name: PackageKitDetailsEvent(
            packageId: id,
            size: id.arch == 'amd64' ? 1000 : 2000,
          ),
      };
    });
    final container = createContainer();
    expect((await container.read(mediaSupportModelProvider.future)).size, 3000);
    for (final dependency in dependencies) {
      verify(kit.getDetails([dependency.packageId])).called(1);
    }
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
    expect(container.read(mediaSupportModelProvider).value!.size, isNull);
    verifyNever(kit.simulateInstall(any));
    verifyNever(kit.getDetails(any));
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
        PackageKitTransactionCancelled('cancelled'),
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
