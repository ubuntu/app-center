import 'package:app_center/deb/local_deb_model.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  final mockPackage = PackageKitPackageDetails(
    packageId: const PackageKitPackageId(name: 'testdeb', version: '1.0'),
    summary: 'summary',
    description: 'description',
    license: 'license',
    size: 42,
    url: 'url',
  );

  tearDown(() async {
    await resetAllServices();
  });

  test(
    'error stream records the error and clears the active transaction',
    () async {
      createMockPackageKitService(
        packageDetails: mockPackage,
        errorStream: Stream.value(
          const PackageKitServiceError(
            code: PackageKitError.internalError,
            details: 'install failed',
          ),
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = container.listen(
        localDebModelProvider(path: '/path/to/package.deb'),
        (_, __) {},
      );

      await expectLater(
        container.read(
          localDebModelProvider(path: '/path/to/package.deb').future,
        ),
        completes,
      );

      expect(provider.read().value?.error, isNotNull);
      expect(
        provider.read().value!.error!.code,
        equals(PackageKitError.internalError),
      );
      expect(provider.read().value!.error!.details, equals('install failed'));
      expect(provider.read().value?.activeTransactionId, isNull);
    },
  );
}
