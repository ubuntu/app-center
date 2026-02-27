import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final container = ProviderContainer();
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
    final container = ProviderContainer();
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
    final container = ProviderContainer();
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    await container.read(debModelProvider('testdeb').notifier).updateDeb();

    verify(
      packageKit.update(
        const PackageKitPackageId(
          name: 'testdeb',
          version: '1.0',
        ),
      ),
    ).called(1);
  });

  test('remove', () async {
    final packageKit = createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
    );
    createMockAppstreamService(component: component);
    final container = ProviderContainer();
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
    final container = ProviderContainer();
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

  // TODO: test `activeTransactionId` and `cancel()`
}
