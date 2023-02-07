import 'dart:async';
import 'dart:io';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/services/packagekit/package_state.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class MockNotification extends Mock implements Notification {}

class MockNotificationsClient extends Mock implements NotificationsClient {}

class MockPackageKitClient extends Mock implements PackageKitClient {}

class MockPackageKitTransaction extends Mock implements PackageKitTransaction {}

void main() {
  late MockPackageKitClient mockPKClient;
  late MockNotificationsClient mockNotificationsClient;

  late MemoryFileSystem testFS;

  const firefoxPackageId =
      PackageKitPackageId(name: 'firefox', version: '105.0.2');

  Future<void> emitFinishedEvent(controller) {
    controller.add(
      const PackageKitFinishedEvent(
        exit: PackageKitExit.success,
        runtime: 10,
      ),
    );
    return Future.value();
  }

  MockPackageKitTransaction createMockTransaction() {
    final transaction = MockPackageKitTransaction();
    final controller = StreamController<PackageKitEvent>.broadcast();
    when(() => transaction.events).thenAnswer((_) => controller.stream);

    when(() => transaction.getRepositoryList())
        .thenAnswer((_) => emitFinishedEvent(controller));

    when(() => transaction.refreshCache())
        .thenAnswer((_) => emitFinishedEvent(controller));

    when(() => transaction.getUpdates(filter: {}))
        .thenAnswer((_) => emitFinishedEvent(controller));

    when(() => transaction.getPackages(filter: {PackageKitFilter.installed}))
        .thenAnswer((_) => emitFinishedEvent(controller));

    when(
      () => transaction.getPackages(
        filter: {
          PackageKitFilter.installed,
          PackageKitFilter.gui,
          PackageKitFilter.newest,
          PackageKitFilter.application,
          PackageKitFilter.notDevelopment,
          PackageKitFilter.notSource,
          PackageKitFilter.visible,
        },
      ),
    ).thenAnswer((_) => emitFinishedEvent(controller));

    when(() => transaction.resolve(['firefox'])).thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.available,
          packageId: firefoxPackageId,
          summary: '',
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(() => transaction.getDetails([firefoxPackageId])).thenAnswer((_) {
      controller.add(
        PackageKitDetailsEvent(
          packageId: firefoxPackageId,
          summary: 'a summary',
          url: 'https://example.org/',
          license: 'a license',
          size: 43008,
          description: 'a description',
          group: PackageKitGroup.internet,
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(() => transaction.searchNames(['fire'], filter: {})).thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: PackageKitPackageId(name: 'firejail', version: '0.9.66-2'),
          summary: 'a jail',
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(() => transaction.setRepositoryEnabled(any(), any()))
        .thenAnswer((_) => emitFinishedEvent(controller));

    when(() => transaction.getDetailsLocal(any())).thenAnswer((_) {
      controller.add(
        PackageKitDetailsEvent(
          packageId: firefoxPackageId,
          group: PackageKitGroup.internet,
          summary: 'a fox',
          description: 'a fire fox',
          url: 'https://example.org/',
          license: 'a license',
          size: 43008,
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(
      () => transaction.searchNames(['firefox']),
    ).thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(() => transaction.installPackages([firefoxPackageId])).thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installing,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.install,
          percentage: 33,
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.install,
          percentage: 67,
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.install,
          percentage: 100,
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(() => transaction.removePackages([firefoxPackageId])).thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.removing,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.remove,
          percentage: 27,
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.remove,
          percentage: 72,
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.remove,
          percentage: 100,
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(() => transaction.installFiles(any())).thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installing,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      return emitFinishedEvent(controller);
    });

    when(
      () => transaction.searchNames(
        [firefoxPackageId.name],
        filter: {PackageKitFilter.installed},
      ),
    ).thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      return emitFinishedEvent(controller);
    });

    return transaction;
  }

  Future<File> createTempFile() async {
    testFS = MemoryFileSystem();
    final tempFile = testFS
        .directory(Directory.systemTemp.absolute.path)
        .childFile('tempfile.deb');
    return tempFile.create(recursive: true);
  }

  PackageModel createPackageModel({
    required PackageService service,
    PackageKitPackageId? packageId,
    String? path,
  }) {
    final model = PackageModel(
      service: service,
      packageId: packageId,
      path: path,
    );
    expect(model.summary, isNull);
    expect(model.url, isNull);
    expect(model.license, isNull);
    expect(model.description, '');
    expect(model.isInstalled, isNull);
    return model;
  }

  setUp(() {
    mockPKClient = MockPackageKitClient();
    registerMockService<PackageKitClient>(mockPKClient);
    when(mockPKClient.connect).thenAnswer((_) async {});
    when(mockPKClient.createTransaction)
        .thenAnswer((_) async => createMockTransaction());

    mockNotificationsClient = MockNotificationsClient();
    registerMockService<NotificationsClient>(mockNotificationsClient);
    when(
      () => mockNotificationsClient.notify(
        any(),
        body: any(named: 'body'),
        appName: any(named: 'appName'),
        appIcon: any(named: 'appIcon'),
        hints: any(named: 'hints'),
      ),
    ).thenAnswer((_) async => MockNotification());
  });

  tearDown(() {
    unregisterMockService<NotificationsClient>();
    unregisterMockService<PackageKitClient>();
  });

  test('instantiate service', () {
    PackageService();

    verify(mockPKClient.connect).called(1);
  });

  test('init', () async {
    final service = PackageService();

    expect(service.isAvailable, isFalse);

    service.init(filters: {PackageKitFilter.installed});
    await service.initialized;

    expect(service.isAvailable, isTrue);
    expect(service.installedPackages, isEmpty);
  });

  test('no updates', () async {
    final service = PackageService();
    expect(service.updates, isEmpty);

    expectLater(
      service.updatesState,
      emitsInOrder(
        [UpdatesState.checkingForUpdates, UpdatesState.noUpdates],
      ),
    );

    await service.refreshUpdates();

    expect(service.lastUpdatesState, UpdatesState.noUpdates);
  });

  test('get details', () async {
    final service = PackageService();
    final model = createPackageModel(
      service: service,
      packageId: firefoxPackageId,
    );

    await service.getDetails(model: model);

    expect(model.summary, 'a summary');
    expect(model.url, 'https://example.org/');
    expect(model.license, 'a license');
    expect(model.size, 43008);
    expect(model.description, 'a description');
  });

  test('is installed', () async {
    final service = PackageService();
    final model = createPackageModel(
      service: service,
      packageId: firefoxPackageId,
    );

    final packageStates = [model.packageState];
    model.addListener(() {
      if (packageStates.last != model.packageState) {
        packageStates.add(model.packageState);
      }
    });

    await service.isInstalled(model: model);

    expect(model.isInstalled, isTrue);
    expect(packageStates, [
      PackageState.ready,
      PackageState.processing,
      PackageState.ready,
    ]);
  });

  test('toggle repo', () async {
    final service = PackageService();

    expectLater(service.reposChanged, emitsInOrder([true, true]));

    await service.toggleRepo(id: 'myrepository', value: true);
    await service.toggleRepo(id: 'myotherrepository', value: false);
  });

  test('send update notification', () async {
    final service = PackageService();

    const body = 'ho ho ho';
    expect(service.lastUpdatesState, isNull);
    service.sendUpdateNotification(updatesAvailable: body);
    verifyNever(
      () => mockNotificationsClient.notify(
        any(),
        body: body,
        appName: any(named: 'appName'),
        appIcon: any(named: 'appIcon'),
        hints: any(named: 'hints'),
      ),
    );

    service.lastUpdatesState = UpdatesState.readyToUpdate;
    service.sendUpdateNotification(updatesAvailable: body);
    verify(
      () => mockNotificationsClient.notify(
        any(),
        body: body,
        appName: any(named: 'appName'),
        appIcon: any(named: 'appIcon'),
        hints: any(named: 'hints'),
      ),
    ).called(1);
  });

  test('resolve package id', () async {
    final service = PackageService();
    expect(await service.resolve('firefox'), firefoxPackageId);
  });

  test('get details about local package', () async {
    final service = PackageService();
    final tempFile = await createTempFile();
    final model = createPackageModel(service: service, path: tempFile.path);

    await service.getDetailsAboutLocalPackage(
      model: model,
      fileSystem: testFS,
    );

    expect(model.packageId, firefoxPackageId);
    expect(model.summary, 'a fox');
    expect(model.url, 'https://example.org/');
    expect(model.license, 'a license');
    expect(model.group, PackageKitGroup.internet);
    expect(model.description, 'a fire fox');
  });

  test('install package', () async {
    final service = PackageService();
    final model = createPackageModel(
      service: service,
      packageId: firefoxPackageId,
    );

    final packageStates = [model.packageState];
    final percentages = [model.percentage];
    model.addListener(() {
      if (packageStates.last != model.packageState) {
        packageStates.add(model.packageState);
      } else if (percentages.last != model.percentage) {
        percentages.add(model.percentage);
      }
    });

    expectLater(service.installedPackagesChanged, emits(true));
    await service.install(model: model);

    expect(model.info, PackageKitInfo.installing);
    expect(model.isInstalled, isTrue);
    expect(packageStates, [
      PackageState.ready,
      PackageState.processing,
      PackageState.ready,
    ]);
    expect(percentages, [0, 33, 67, 100]);
    expect(service.installedPackages.contains(model.packageId), isTrue);
  });

  test('remove package', () async {
    final service = PackageService();
    final model = createPackageModel(
      service: service,
      packageId: firefoxPackageId,
    );
    model.isInstalled = true;
    model.percentage = 100;

    final packageStates = [model.packageState];
    final percentages = [model.percentage];
    model.addListener(() {
      if (packageStates.last != model.packageState) {
        packageStates.add(model.packageState);
      } else if (percentages.last != model.percentage) {
        percentages.add(model.percentage);
      }
    });

    expectLater(service.installedPackagesChanged, emits(true));
    await service.remove(model: model);

    expect(model.info, PackageKitInfo.removing);
    expect(model.isInstalled, isFalse);
    expect(packageStates, [
      PackageState.ready,
      PackageState.processing,
      PackageState.ready,
    ]);
    expect(percentages, [100, 73, 28, 0]);
    expect(service.installedPackages.contains(model.packageId), isFalse);
  });

  test('install local file', () async {
    final service = PackageService();
    final tempFile = await createTempFile();
    final model = createPackageModel(service: service, path: tempFile.path);

    final packageStates = [model.packageState];
    model.addListener(() {
      if (packageStates.last != model.packageState) {
        packageStates.add(model.packageState);
      }
    });

    expectLater(service.installedPackagesChanged, emits(true));
    await service.installLocalFile(model: model, fileSystem: testFS);

    expect(model.packageId, firefoxPackageId);
    expect(model.info, PackageKitInfo.installing);
    expect(model.isInstalled, isTrue);
    expect(packageStates, [
      PackageState.ready,
      PackageState.processing,
      PackageState.ready,
    ]);
    expect(service.installedPackages.contains(model.packageId), isTrue);
  });

  MockPackageKitTransaction createMockUpdateTransaction() {
    final updateTransaction = MockPackageKitTransaction();
    final controller = StreamController<PackageKitEvent>.broadcast();
    when(() => updateTransaction.events).thenAnswer((_) => controller.stream);

    when(updateTransaction.getRepositoryList)
        .thenAnswer((_) => emitFinishedEvent(controller));
    when(() => updateTransaction.getUpdates(filter: any(named: 'filter')))
        .thenAnswer((_) {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      return emitFinishedEvent(controller);
    });
    when(updateTransaction.refreshCache)
        .thenAnswer((_) => emitFinishedEvent(controller));
    when(() => updateTransaction.updatePackages([firefoxPackageId]))
        .thenAnswer((_) async {
      controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.updating,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.update,
          percentage: 13,
        ),
      );
      controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.update,
          percentage: 37,
        ),
      );
      controller.add(
        const PackageKitRequireRestartEvent(
          type: PackageKitRestart.application,
          packageId: firefoxPackageId,
        ),
      );
      return emitFinishedEvent(controller);
    });
    when(
      () => updateTransaction.getDetails(any(that: contains(firefoxPackageId))),
    ).thenAnswer((_) => emitFinishedEvent(controller));
    return updateTransaction;
  }

  test('update all', () async {
    final updateTransaction = createMockUpdateTransaction();
    when(mockPKClient.createTransaction)
        .thenAnswer((_) async => updateTransaction);

    final service = PackageService();
    await service.refreshUpdates();
    expect(service.updates.length, 1);

    expectLater(service.info, emits(PackageKitInfo.updating));
    expectLater(service.updatesPercentage, emitsInOrder([13, 37]));
    expectLater(service.requireRestart, emits(PackageKitRestart.application));
    expectLater(service.status, emits(PackageKitStatus.update));
    await service.updateAll(updatesComplete: 'foo', updatesAvailable: 'bar');
  });

  test('select updates', () async {
    final updateTransaction = createMockUpdateTransaction();
    when(mockPKClient.createTransaction)
        .thenAnswer((_) async => updateTransaction);

    final service = PackageService();
    await service.refreshUpdates();
    expect(service.isUpdateSelected(firefoxPackageId), isTrue);
    service.selectionChanged.listen(expectAsync1((_) {}, count: 3));
    service.deselectAll();
    expect(service.nothingSelected, isTrue);
    service.selectAll();
    expect(service.allSelected, isTrue);
    expect(service.selectedUpdatesLength, 1);
    service.selectUpdate(firefoxPackageId, false);
    expect(service.isUpdateSelected(firefoxPackageId), isFalse);
    expect(service.nothingSelected, isTrue);
  });
}
