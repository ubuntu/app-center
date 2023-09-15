import 'package:app_center/src/deb/deb_model.dart';
import 'package:app_center/src/packagekit/packagekit_service.dart';
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
    final appstream = createMockAppstreamService(component: component);
    final model = DebModel(
      appstream: appstream,
      packageKit: packageKit,
      id: 'testdeb',
    );

    await model.init();

    verify(packageKit.activateService()).called(1);
    expect(model.state.hasValue, isTrue);
    expect(model.packageInfo, equals(packageInfo));
  });

  test('install', () async {
    final packageKit = createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
    );
    final appstream = createMockAppstreamService(component: component);
    final model = DebModel(
      appstream: appstream,
      packageKit: packageKit,
      id: 'testdeb',
    );

    await model.init();
    await model.install();

    verify(
      packageKit.install(const PackageKitPackageId(
        name: 'testdeb',
        version: '1.0',
      )),
    ).called(1);
  });
  test('remove', () async {
    final packageKit = createMockPackageKitService(
      packageInfo: packageInfo,
      transactionId: 42,
    );
    final appstream = createMockAppstreamService(component: component);
    final model = DebModel(
      appstream: appstream,
      packageKit: packageKit,
      id: 'testdeb',
    );

    await model.init();
    await model.remove();

    verify(
      packageKit.remove(const PackageKitPackageId(
        name: 'testdeb',
        version: '1.0',
      )),
    ).called(1);
  });

  // TODO: test `activeTransactionId` and `cancel()`
}
