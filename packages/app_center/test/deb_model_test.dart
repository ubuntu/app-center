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
      packageUpdates: PackageKitUpdateDetailEvent(
        packageId: packageInfo.packageId,
      ),
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

  test('hasUpdate when an installable update exists', () async {
    const updateId = PackageKitPackageId(name: 'testdeb', version: '2.0');
    createMockPackageKitService(
      packageInfo: packageInfo,
      packageUpdates: PackageKitUpdateDetailEvent(
        packageId: packageInfo.packageId,
        updates: [updateId],
      ),
      availableUpdates: [
        const PackageKitPackageInfo(
          info: PackageKitInfo.normal,
          packageId: updateId,
          summary: 'update',
        ),
      ],
      resolveMap: {
        'testdeb-package': packageInfo,
        'testdeb': const PackageKitPackageInfo(
          info: PackageKitInfo.installed,
          packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
          summary: 'summary',
        ),
      },
    );
    createMockAppstreamService(component: component);
    final container = ProviderContainer();
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    expect(
      container.read(debModelProvider('testdeb')).value!.hasUpdate,
      isTrue,
    );
  });

  test('no hasUpdate when the update is blocked (phased)', () async {
    // Blocked updates are filtered out of PackageKitService.getUpdates, so
    // an update listed only in getUpdateDetails must not mark the deb as
    // updatable.
    const updateId = PackageKitPackageId(name: 'testdeb', version: '2.0');
    createMockPackageKitService(
      packageInfo: packageInfo,
      packageUpdates: PackageKitUpdateDetailEvent(
        packageId: packageInfo.packageId,
        updates: [updateId],
      ),
      availableUpdates: [],
    );
    createMockAppstreamService(component: component);
    final container = ProviderContainer();
    container.listen(debModelProvider('testdeb'), (_, __) {});

    await expectLater(
      container.read(debModelProvider('testdeb').future),
      completes,
    );

    expect(
      container.read(debModelProvider('testdeb')).value!.hasUpdate,
      isFalse,
    );
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
