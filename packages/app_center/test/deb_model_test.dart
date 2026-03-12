import 'dart:async';

import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';

import 'test_utils.dart';

const packageInfo = PackageKitPackageInfo(
  info: PackageKitInfo.available,
  packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
  summary: 'summary',
);

const component = AppstreamComponent(
  id: 'testdeb',
  type: AppstreamComponentType.desktopApplication,
  package: 'testdeb-package',
  name: {'C': 'Test Deb Package'},
  summary: {'C': 'Appstream summary'},
);

void main() {
  test('init', () async {
    final packageKit = createMockPackageKitService(packageInfo: packageInfo);
    createMockAppstreamService(component: component);
    final container = createContainer(overrides: emptyDebOverrides);
    final provider = container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    verify(packageKit.activateService()).called(1);

    expect(provider.read().hasValue, isTrue);
    expect(provider.read().value!.packageInfo, equals(packageInfo));
  });

  test('install', () async {
    final packageKit = createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
    );
    createMockAppstreamService(component: component);
    final container = createContainer(overrides: emptyDebOverrides);
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    await container.read(debModelProvider('testdeb').notifier).installDeb();

    verify(
      packageKit.install(
        const PackageKitPackageId(
          name: 'testdeb',
          version: '1.0',
        ),
      ),
    ).called(1);
  });

  test('update', () async {
    final packageKit = createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
      packageUpdates:
          PackageKitUpdateDetailEvent(packageId: packageInfo.packageId),
    );
    createMockAppstreamService(component: component);
    final container = createContainer(overrides: emptyDebOverrides);
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    const updatePackageId = PackageKitPackageId(
      name: 'testdeb',
      version: '2.0',
    );
    await container
        .read(debModelProvider('testdeb').notifier)
        .updateDeb(updatePackageId);

    verify(packageKit.update(updatePackageId)).called(1);
  });

  test('remove', () async {
    final packageKit = createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
    );
    createMockAppstreamService(component: component);
    final container = createContainer(overrides: emptyDebOverrides);
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    await container.read(debModelProvider('testdeb').notifier).removeDeb();

    verify(
      packageKit.remove(
        const PackageKitPackageId(
          name: 'testdeb',
          version: '1.0',
        ),
      ),
    ).called(1);
  });

  test('active transaction id is set during operation', () async {
    final completer = Completer<void>();
    createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
      waitTransaction: completer.future,
    );
    createMockAppstreamService(component: component);
    final container = createContainer(overrides: emptyDebOverrides);
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    // Before any operation, no active transaction
    expect(
      container.read(debModelProvider('testdeb')).value!.activeTransactionId,
      isNull,
    );

    // Start the operation but don't let it complete yet
    final installFuture =
        container.read(debModelProvider('testdeb').notifier).installDeb();

    // Allow microtasks to run so the model sets the transaction id
    await Future<void>.delayed(Duration.zero);

    // During the operation, activeTransactionId should be set
    expect(
      container.read(debModelProvider('testdeb')).value!.activeTransactionId,
      equals(42),
    );

    // Let the transaction complete
    completer.complete();
    await installFuture;

    // After operation completes, activeTransactionId should be cleared
    expect(
      container.read(debModelProvider('testdeb')).value!.activeTransactionId,
      isNull,
    );
  });

  test('cancel transaction', () async {
    final packageKit = createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
    );
    createMockAppstreamService(component: component);
    final container = createContainer(overrides: emptyDebOverrides);
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    // cancelTransaction should not throw when there's no active transaction
    await container
        .read(debModelProvider('testdeb').notifier)
        .cancelTransaction();
    verifyNever(packageKit.cancelTransaction(any));
  });

  test('error stream', () async {
    createMockPackageKitService(
      packageInfo: packageInfo,
      errorStream: Stream.value(
        const PackageKitServiceError(
          code: PackageKitError.noNetwork,
          details: 'error details',
        ),
      ),
    );
    createMockAppstreamService(component: component);
    final container = createContainer(overrides: emptyDebOverrides);
    final provider = container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    expect(provider.read().value?.error, isNotNull);
    expect(
      provider.read().value!.error!.code,
      equals(PackageKitError.noNetwork),
    );
    expect(
      provider.read().value!.error!.details,
      equals('error details'),
    );
  });
}
