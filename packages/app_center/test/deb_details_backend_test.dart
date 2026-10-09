import 'dart:async';

import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/deb/deb_details_backend.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/current_desktops_provider.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

final _refProvider = Provider<Ref>((ref) => ref);

const _installedId = PackageKitPackageId(
  name: 'test-app',
  version: '1.0-1',
  arch: 'amd64',
);
const _updateId = PackageKitPackageId(
  name: 'test-app',
  version: '1.1-1',
  arch: 'amd64',
);

final _component = AppstreamComponent(
  id: 'org.test.app',
  type: AppstreamComponentType.desktopApplication,
  package: 'test-app',
  name: const {'C': 'Test App'},
  summary: const {'C': 'summary'},
  description: const {'C': '<p>description</p>'},
  developerName: const {'C': 'Developer'},
  projectLicense: 'GPL-3.0',
  categories: const ['Graphics', 'RasterGraphics', 'Unknown'],
  compulsoryForDesktops: const ['GNOME'],
  languages: const [AppstreamLanguage('de', percentage: 90)],
  contentRatings: const {
    'oars-1.1': {
      'violence-cartoon': AppstreamContentRating.mild,
      'language-humor': AppstreamContentRating.moderate,
    },
  },
  releases: [AppstreamRelease(version: '1.0-1', date: DateTime(2026, 1, 5))],
);

DebData _data({
  PackageKitInfo info = PackageKitInfo.installed,
  PackageKitPackageId? updatePackageId,
  int? activeTransactionId,
  DebTransactionKind? activeTransactionKind,
  bool withPackage = true,
}) {
  final subscription = const Stream<PackageKitServiceError>.empty().listen(
    null,
  );
  addTearDown(subscription.cancel);
  return DebData(
    id: 'org.test.app',
    component: _component,
    hasUpdate: updatePackageId != null,
    updatePackageId: updatePackageId,
    errorStream: subscription,
    packageInfo: withPackage
        ? PackageKitPackageEvent(
            info: info,
            packageId: _installedId,
            summary: 'summary',
          )
        : null,
    details: PackageKitDetailsEvent(packageId: _installedId, size: 40),
    activeTransactionId: activeTransactionId,
    activeTransactionKind: activeTransactionKind,
  );
}

void main() {
  tearDown(resetAllServices);

  group('mapping', () {
    test('uninstalled deb', () {
      final snapshot = debSnapshotFromData(
        _data(info: PackageKitInfo.available),
        installSize: const FieldState.value(
          ByteSize(bytes: 90, kind: SizeKind.download),
        ),
      );

      expect(snapshot.key, testDebKey);
      expect(snapshot.installState, InstallState.notInstalled);
      expect(snapshot.appName.valueOrNull, 'Test App');
      expect(snapshot.description.valueOrNull?.type, RichContentType.html);
      expect(snapshot.publisher.valueOrNull?.name, 'Developer');
      expect(snapshot.categories.valueOrNull, [AppCategory.artAndDesign]);
      expect(snapshot.ageRating.valueOrNull, ContentRatingLevel.moderate);
      expect(snapshot.languages.valueOrNull, ['de']);
      expect(snapshot.terms, isA<FieldUnavailable<String>>());
      expect(snapshot.installDate, isA<FieldUnavailable<DateTime>>());
      expect(snapshot.installCandidate?.candidateId, '$_installedId');
      expect(snapshot.installCandidate?.size.valueOrNull?.bytes, 90);
      expect(
        snapshot.installCandidate?.size.valueOrNull?.kind,
        SizeKind.download,
      );
      expect(
        snapshot.installCandidate?.releaseDate.valueOrNull,
        DateTime(2026, 1, 5),
      );
      expect(snapshot.targets.single.isInstalled, isFalse);
    });

    test('installed deb with an exact update candidate', () {
      final snapshot = debSnapshotFromData(
        _data(updatePackageId: _updateId),
        updateSize: const FieldState.value(
          ByteSize(bytes: 45, kind: SizeKind.download),
        ),
        currentDesktops: ['ubuntu', 'GNOME'],
      );

      expect(snapshot.installState, InstallState.installed);
      expect(snapshot.installed?.version, '1.0-1');
      // PackageKit's size for an installed package is ambiguous.
      expect(snapshot.installed?.size, isA<FieldUnavailable<ByteSize>>());
      expect(snapshot.updateCandidate?.candidateId, '$_updateId');
      expect(snapshot.updateCandidate?.size.valueOrNull?.bytes, 45);
      expect(
        snapshot.updateCandidate?.releaseDate,
        isA<FieldUnavailable<DateTime>>(),
      );
      expect(
        snapshot.capabilities.removeBlocked,
        DisabledReason.protectedPackage,
      );
      expect(snapshot.capabilities.canLaunch, isFalse);
    });

    test('missing package info is unknown, not uninstalled', () {
      final snapshot = debSnapshotFromData(_data(withPackage: false));
      expect(snapshot.installState, InstallState.unknown);
      expect(snapshot.targets, isEmpty);
    });

    test('own transaction is cancellable with progress', () {
      final snapshot = debSnapshotFromData(
        _data(
          info: PackageKitInfo.available,
          activeTransactionId: 7,
          activeTransactionKind: DebTransactionKind.install,
        ),
        mutations: const [
          PackageKitMutation(
            transactionId: 7,
            kind: PackageKitMutationKind.install,
            packageIds: [_installedId],
            percentage: 40,
          ),
        ],
      );
      final operation = snapshot.activeOperation!;
      expect(operation.kind, OperationKind.install);
      expect(operation.targetId, 'test-app');
      expect(operation.progress, 0.4);
      expect(operation.cancellable, isTrue);
    });

    test('mutations started elsewhere are observed but not owned', () {
      final snapshot = debSnapshotFromData(
        _data(),
        mutations: const [
          PackageKitMutation(
            transactionId: 3,
            kind: PackageKitMutationKind.update,
            packageIds: [
              _updateId,
              PackageKitPackageId(name: 'other', version: '1'),
            ],
          ),
        ],
      );
      expect(snapshot.activeOperation?.kind, OperationKind.update);
      expect(snapshot.activeOperation?.cancellable, isFalse);
      expect(snapshot.activeOperation?.progress, isNull);
    });

    test('unrelated and finished mutations are ignored', () {
      final snapshot = debSnapshotFromData(
        _data(),
        mutations: const [
          PackageKitMutation(
            transactionId: 3,
            kind: PackageKitMutationKind.remove,
            packageIds: [PackageKitPackageId(name: 'other', version: '1')],
          ),
          PackageKitMutation(
            transactionId: 4,
            kind: PackageKitMutationKind.remove,
            packageIds: [_installedId],
            outcome: PackageKitMutationOutcome.success,
          ),
        ],
      );
      expect(snapshot.activeOperation, isNull);
    });
  });

  group('install size', () {
    const dependencyId = PackageKitPackageId(
      name: 'test-lib',
      version: '2.0',
      arch: 'amd64',
    );

    Future<ByteSize?> installSize() =>
        createContainer().read(debInstallSizeProvider(_installedId).future);

    test('includes the dependencies an install adds', () async {
      createMockPackageKitService(
        simulatedInstall: const [
          PackageKitPackageEvent(
            info: PackageKitInfo.installing,
            packageId: _installedId,
            summary: '',
          ),
          PackageKitPackageEvent(
            info: PackageKitInfo.installing,
            packageId: dependencyId,
            summary: '',
          ),
        ],
        packageDetailsMany: {
          'test-app': PackageKitDetailsEvent(packageId: _installedId, size: 40),
          'test-lib': PackageKitDetailsEvent(packageId: dependencyId, size: 60),
        },
      );

      final size = await installSize();
      expect(size?.bytes, 100);
      expect(size?.kind, SizeKind.download);
    });

    test('falls back to the package itself if simulation fails', () async {
      final packageKit = createMockPackageKitService(
        packageDetailsMany: {
          'test-app': PackageKitDetailsEvent(packageId: _installedId, size: 40),
        },
      );
      when(
        packageKit.simulateInstall(any),
      ).thenThrow(Exception('simulation failed'));

      expect((await installSize())?.bytes, 40);
    });

    test('is unknown when a package has no details', () async {
      createMockPackageKitService(
        simulatedInstall: const [
          PackageKitPackageEvent(
            info: PackageKitInfo.installing,
            packageId: dependencyId,
            summary: '',
          ),
        ],
        packageDetailsMany: const {},
      );

      expect(await installSize(), isNull);
    });
  });

  group('commands', () {
    const backend = DebDetailsBackend();

    ProviderContainer setUpServices({
      PackageKitInfo info = PackageKitInfo.installed,
      bool withUpdate = false,
      List<String> desktops = const ['KDE'],
    }) {
      final installedInfo = PackageKitPackageEvent(
        info: info,
        packageId: _installedId,
        summary: 'summary',
      );
      createMockAppstreamService(component: _component);
      createMockPackageKitService(
        transactionId: 5,
        resolveMap: {'test-app': installedInfo},
        packageUpdates: withUpdate
            ? const PackageKitUpdateDetailEvent(
                packageId: _installedId,
                updates: [_updateId],
              )
            : null,
        availableUpdates: [
          if (withUpdate)
            const PackageKitPackageEvent(
              info: PackageKitInfo.normal,
              packageId: _updateId,
              summary: 'update',
            ),
        ],
      );
      return createContainer(
        overrides: [currentDesktopsProvider.overrideWithValue(desktops)],
      );
    }

    Future<OperationOutcome> execute(
      ProviderContainer container,
      OperationKind kind, {
      String? candidateId,
    }) => backend.execute(
      container.read(_refProvider),
      testDebKey,
      PackageCommand(kind: kind, candidateId: candidateId),
    );

    test('installs', () async {
      final container = setUpServices(info: PackageKitInfo.available);
      final packageKit =
          getService<PackageKitService>() as MockPackageKitService;

      expect(
        await execute(container, OperationKind.install),
        OperationOutcome.success,
      );
      verify(packageKit.install(_installedId)).called(1);
    });

    test('updates to the exact candidate', () async {
      final container = setUpServices(withUpdate: true);
      final packageKit =
          getService<PackageKitService>() as MockPackageKitService;

      expect(
        await execute(
          container,
          OperationKind.update,
          candidateId: '$_updateId',
        ),
        OperationOutcome.success,
      );
      verify(packageKit.update(_updateId)).called(1);
    });

    test('refuses a stale update candidate', () async {
      final container = setUpServices(withUpdate: true);
      final packageKit =
          getService<PackageKitService>() as MockPackageKitService;

      expect(
        await execute(container, OperationKind.update, candidateId: 'old'),
        OperationOutcome.failed,
      );
      verifyNever(packageKit.update(any));
    });

    test('refuses to remove a compulsory package', () async {
      final container = setUpServices(desktops: ['GNOME']);
      final packageKit =
          getService<PackageKitService>() as MockPackageKitService;

      expect(
        await execute(container, OperationKind.remove),
        OperationOutcome.failed,
      );
      verifyNever(packageKit.remove(any));
    });

    test('removes', () async {
      final container = setUpServices();
      final packageKit =
          getService<PackageKitService>() as MockPackageKitService;

      expect(
        await execute(container, OperationKind.remove),
        OperationOutcome.success,
      );
      verify(packageKit.remove(_installedId)).called(1);
    });

    test('declined authorization is a cancellation', () async {
      final container = setUpServices(info: PackageKitInfo.available);
      when(
        (getService<PackageKitService>() as MockPackageKitService)
            .waitTransaction(any),
      ).thenAnswer(
        (_) => Future.error(PackageKitTransactionCancelled('declined')),
      );
      expect(
        await execute(container, OperationKind.install),
        OperationOutcome.cancelled,
      );
    });

    test('channel switch is not supported', () async {
      final container = setUpServices();
      expect(
        await execute(container, OperationKind.switchChannel),
        OperationOutcome.failed,
      );
    });
  });
}
