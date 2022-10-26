import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/services/package_model.dart';
import 'package:software/services/package_service.dart';

import 'package_model_test.mocks.dart';

@GenerateMocks([PackageService])
void main() {
  const firefoxPackageId =
      PackageKitPackageId(name: 'firefox', version: '106.0.2');

  final service = MockPackageService();

  setUp(() => reset(service));

  test('instantiate model', () {
    expect(
      () => PackageModel(service: service, packageId: null, path: null),
      throwsException,
    );

    var model = PackageModel(service: service, packageId: firefoxPackageId);
    expect(model.packageId, isNotNull);
    expect(model.packageId!.name, 'firefox');
    expect(model.path, isNull);

    model = PackageModel(service: service, path: '/some/path/to/file.deb');
    expect(model.packageId, isNull);
    expect(model.path, isNotNull);
    expect(model.path, '/some/path/to/file.deb');
  });

  test('init model', () async {
    var model = PackageModel(service: service, packageId: firefoxPackageId);
    await model.init();
    verify(service.getDetails(model: model)).called(1);
    verify(service.isInstalled(model: model)).called(1);
    verifyNever(service.getUpdateDetail(model: model));
    verifyNever(service.getDetailsAboutLocalPackage(model: model));

    reset(service);
    await model.init(update: true);
    verify(service.getDetails(model: model)).called(1);
    verify(service.isInstalled(model: model)).called(1);
    verify(service.getUpdateDetail(model: model)).called(1);
    verifyNever(service.getDetailsAboutLocalPackage(model: model));

    reset(service);
    model = PackageModel(service: service, path: '/some/path/to/file.deb');
    await model.init();
    verify(service.getDetailsAboutLocalPackage(model: model)).called(1);
    verify(service.isInstalled(model: model)).called(1);
    verifyNever(service.getDetails(model: model));
    verifyNever(service.getUpdateDetail(model: model));
  });

  test('update percentage', () async {
    final model = PackageModel(service: service, packageId: firefoxPackageId);

    model.isInstalled = true;
    await model.init();
    expect(model.percentage, 100);

    model.isInstalled = false;
    await model.init();
    expect(model.percentage, 0);
  });

  test('install', () async {
    var model = PackageModel(service: service, packageId: firefoxPackageId);
    await model.install();
    verify(service.install(model: model)).called(1);
    verifyNever(service.installLocalFile(model: model));

    reset(service);
    model = PackageModel(service: service, path: '/some/path/to/file.deb');
    when(service.installLocalFile(model: model)).thenAnswer((_) {
      model.packageId = firefoxPackageId;
      return Future.value();
    });
    await model.install();
    verify(service.installLocalFile(model: model)).called(1);
    verifyNever(service.install(model: model));
  });

  test('remove', () async {
    final model = PackageModel(service: service, packageId: firefoxPackageId);
    await model.remove();
    verify(service.remove(model: model)).called(1);
  });
}
