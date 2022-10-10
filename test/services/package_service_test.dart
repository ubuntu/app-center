import 'dart:async';
import 'dart:io';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:path/path.dart' as p;
import 'package:software/package_state.dart';
import 'package:software/services/package_service.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'package_service_test.mocks.dart';

class MockTransaction extends MockPackageKitTransaction {
  final StreamController<PackageKitEvent> controller =
      StreamController<PackageKitEvent>.broadcast();

  MockTransaction() {
    when(events).thenAnswer((_) => controller.stream);
  }
}

@GenerateMocks([
  Notification,
  NotificationsClient,
  PackageKitClient,
  PackageKitTransaction,
])
void main() {
  late MockPackageKitClient mockPKClient;
  late MockNotificationsClient mockNotificationsClient;

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

  MockTransaction createMockTransaction() {
    final transaction = MockTransaction();

    when(transaction.getRepositoryList())
        .thenAnswer((_) => emitFinishedEvent(transaction.controller));

    when(transaction.refreshCache())
        .thenAnswer((_) => emitFinishedEvent(transaction.controller));

    when(transaction.getUpdates(filter: {}))
        .thenAnswer((_) => emitFinishedEvent(transaction.controller));

    when(transaction.getPackages(filter: {PackageKitFilter.installed}))
        .thenAnswer((_) => emitFinishedEvent(transaction.controller));

    when(
      transaction.getPackages(
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
    ).thenAnswer((_) => emitFinishedEvent(transaction.controller));

    when(transaction.getDetails([firefoxPackageId])).thenAnswer((_) {
      transaction.controller.add(
        PackageKitDetailsEvent(
            packageId: firefoxPackageId,
            summary: 'a summary',
            url: 'https://example.org/',
            license: 'a license',
            size: 43008,
            description: 'a description',
            group: PackageKitGroup.internet),
      );
      return emitFinishedEvent(transaction.controller);
    });

    when(transaction.searchNames(['fire'], filter: {})).thenAnswer((_) {
      transaction.controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      transaction.controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: PackageKitPackageId(name: 'firejail', version: '0.9.66-2'),
          summary: 'a jail',
        ),
      );
      return emitFinishedEvent(transaction.controller);
    });

    when(transaction.setRepositoryEnabled(any, any))
        .thenAnswer((_) => emitFinishedEvent(transaction.controller));

    when(transaction.getDetailsLocal(any)).thenAnswer((_) {
      transaction.controller.add(
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
      return emitFinishedEvent(transaction.controller);
    });

    when(transaction.searchNames(['firefox'],
        filter: {PackageKitFilter.installed})).thenAnswer((_) {
      transaction.controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installed,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      return emitFinishedEvent(transaction.controller);
    });

    when(transaction.installPackages([firefoxPackageId])).thenAnswer((_) {
      transaction.controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.installing,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      transaction.controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.install,
          percentage: 33,
        ),
      );
      transaction.controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.install,
          percentage: 67,
        ),
      );
      transaction.controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.install,
          percentage: 100,
        ),
      );
      return emitFinishedEvent(transaction.controller);
    });

    when(transaction.removePackages([firefoxPackageId])).thenAnswer((_) {
      transaction.controller.add(
        const PackageKitPackageEvent(
          info: PackageKitInfo.removing,
          packageId: firefoxPackageId,
          summary: 'a fox',
        ),
      );
      transaction.controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.remove,
          percentage: 27,
        ),
      );
      transaction.controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.remove,
          percentage: 72,
        ),
      );
      transaction.controller.add(
        const PackageKitItemProgressEvent(
          packageId: firefoxPackageId,
          status: PackageKitStatus.remove,
          percentage: 100,
        ),
      );
      return emitFinishedEvent(transaction.controller);
    });

    return transaction;
  }

  setUp(() {
    mockPKClient = MockPackageKitClient();
    registerMockService<PackageKitClient>(mockPKClient);
    when(mockPKClient.createTransaction())
        .thenAnswer((_) => Future.value(createMockTransaction()));

    mockNotificationsClient = MockNotificationsClient();
    registerMockService<NotificationsClient>(mockNotificationsClient);
    when(mockNotificationsClient.notify(any,
            body: anyNamed('body'),
            appName: anyNamed('appName'),
            appIcon: anyNamed('appIcon'),
            hints: anyNamed('hints')))
        .thenAnswer((_) => Future.value(MockNotification()));
  });

  tearDown(() {
    unregisterMockService<NotificationsClient>();
    unregisterMockService<PackageKitClient>();
  });

  test('instantiate service', () {
    // ignore: unused_local_variable
    final service = PackageService();

    verify(mockPKClient.connect()).called(1);
  });

  test('init', () async {
    final service = PackageService();

    expectLater(
      service.packageState,
      emitsInOrder(
        [PackageState.processing, PackageState.ready],
      ),
    );

    await service.init();
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

    expectLater(service.summary, emits('a summary'));
    expectLater(service.url, emits('https://example.org/'));
    expectLater(service.license, emits('a license'));
    expectLater(service.size, emits('42.00 KB'));
    expectLater(service.description, emits('a description'));

    await service.getDetails(packageId: firefoxPackageId);
  });

  test('find package ids', () async {
    final service = PackageService();

    final results = await service.findPackageKitPackageIds(searchQuery: 'fire');
    expect(results.length, 2);
    expect(results[0], firefoxPackageId);
    expect(
      results[1],
      const PackageKitPackageId(name: 'firejail', version: '0.9.66-2'),
    );
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
      mockNotificationsClient.notify(
        any,
        body: body,
        appName: anyNamed('appName'),
        appIcon: anyNamed('appIcon'),
        hints: anyNamed('hints'),
      ),
    );

    service.lastUpdatesState = UpdatesState.readyToUpdate;
    service.sendUpdateNotification(updatesAvailable: body);
    verify(
      mockNotificationsClient.notify(
        any,
        body: body,
        appName: anyNamed('appName'),
        appIcon: anyNamed('appIcon'),
        hints: anyNamed('hints'),
      ),
    ).called(1);
  });

  test('get details about local package', () async {
    final service = PackageService();

    final tempFile = File(p.join(Directory.systemTemp.path, 'tempfile.deb'));
    await tempFile.openSync(mode: FileMode.write).close();

    expectLater(service.processedId, emits(firefoxPackageId));
    expectLater(service.summary, emits('a fox'));
    expectLater(service.url, emits('https://example.org/'));
    expectLater(service.license, emits('a license'));
    expectLater(service.size, emits('42.00 KB'));
    expectLater(service.group, emits(PackageKitGroup.internet));
    expectLater(service.description, emits('a fire fox'));

    await service.getDetailsAboutLocalPackage(path: tempFile.path);

    await tempFile.delete();
  });

  test('install package', () async {
    final service = PackageService();

    expectLater(
      service.packageState,
      emitsInOrder(
        [
          PackageState.processing,
          PackageState.processing,
          PackageState.ready,
          PackageState.ready,
        ],
      ),
    );
    expectLater(service.info, emitsInOrder([PackageKitInfo.installing]));
    expectLater(service.packagePercentage, emitsInOrder([33, 67, 100]));

    await service.install(packageId: firefoxPackageId);
  });

  test('remove package', () async {
    final service = PackageService();

    expectLater(
      service.packageState,
      emitsInOrder(
        [
          PackageState.processing,
          PackageState.processing,
          PackageState.ready,
          PackageState.ready,
        ],
      ),
    );
    expectLater(service.info, emitsInOrder([PackageKitInfo.removing]));
    expectLater(service.packagePercentage, emitsInOrder([73, 28, 0]));

    await service.remove(packageId: firefoxPackageId);
  });
}
