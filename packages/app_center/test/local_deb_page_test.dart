import 'dart:async';

import 'package:app_center/deb/deb.dart';
import 'package:app_center/deb/local_deb_model.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/current_desktops_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_test/yaru_test.dart';

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

  setUp(createMockAppstreamService);

  tearDown(() async {
    await resetAllServices();
  });

  testWidgets('package details', (tester) async {
    final packageKit = createMockPackageKitService(packageDetails: mockPackage);
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    expect(find.text('testdeb'), findsOneWidget);
    expect(find.text('summary'), findsOneWidget);
    expect(find.text('description'), findsOneWidget);
    expect(find.text('license'), findsOneWidget);
    expect(find.text(tester.context.formatByteSize(42)), findsOneWidget);
    expect(find.text(tester.l10n.appUrlTypeHomepage), findsOneWidget);
    expect(find.button(tester.l10n.snapActionInstallLabel), findsOneWidget);
    expect(find.button(tester.l10n.snapActionRemoveLabel), findsNothing);
  });

  testWidgets('installed package', (tester) async {
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
    );
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    expect(find.button(tester.l10n.snapActionInstalledLabel), isDisabled);
    expect(find.button(tester.l10n.snapActionRemoveLabel), isEnabled);
    expect(
      find.text(tester.l10n.localDebInstalledVersion('1.0')),
      findsOneWidget,
    );
    verify(
      packageKit.resolve(['testdeb'], installedOnly: true),
    ).called(1);
  });

  testWidgets('uninstall', (tester) async {
    final transactionCompleter = Completer();
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
      waitTransaction: transactionCompleter.future,
    );

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    await tester.tapButton(tester.l10n.snapActionRemoveLabel);
    await tester.pump();

    final removed =
        verify(
              packageKit.remove(captureAny, allowDeps: true),
            ).captured.single
            as PackageKitPackageId;
    expect(removed.name, 'testdeb');
    expect(removed.version, '1.0');
    verifyNever(packageKit.installLocal(any));
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);
    expect(find.text(tester.l10n.snapActionRemovingLabel), findsOneWidget);
    expect(find.text(tester.l10n.snapActionInstallingLabel), findsNothing);
    expect(find.button(tester.l10n.snapActionRemoveLabel), findsNothing);

    transactionCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.byType(YaruCircularProgressIndicator), findsNothing);
  });

  testWidgets('failed uninstall reports the error and restores the actions', (
    tester,
  ) async {
    // ignore: close_sinks
    final errors = registerMockErrorStreamControllerService();
    final transactionCompleter = Completer<void>();
    final error = PackageKitServiceError(
      code: PackageKitError.internalError,
      details: 'removal failed',
    );
    createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
      waitTransaction: transactionCompleter.future,
      lastError: error,
    );

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    await tester.tapButton(tester.l10n.snapActionRemoveLabel);
    await tester.pump();

    transactionCompleter.completeError(PackageKitTransactionError('failed'));
    await tester.pumpAndSettle();

    expect(find.text(tester.l10n.snapActionRemovingLabel), findsNothing);
    expect(find.button(tester.l10n.snapActionRemoveLabel), isEnabled);
    verify(errors.add(error)).called(1);
  });

  testWidgets('double clicking uninstall starts one transaction', (
    tester,
  ) async {
    final removeCompleter = Completer<int>();
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
    );
    when(
      packageKit.remove(any, allowDeps: anyNamed('allowDeps')),
    ).thenAnswer((_) => removeCompleter.future);

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    await tester.tapButton(tester.l10n.snapActionRemoveLabel);
    await tester.tapButton(tester.l10n.snapActionRemoveLabel);
    removeCompleter.complete(0);
    await tester.pumpAndSettle();

    verify(packageKit.remove(any, allowDeps: true)).called(1);
  });

  testWidgets('actions return only once a cancel lands', (tester) async {
    // ignore: close_sinks
    final errors = registerMockErrorStreamControllerService();
    final transactionCompleter = Completer<void>();
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
      waitTransaction: transactionCompleter.future,
    );

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    await tester.tapButton(tester.l10n.snapActionRemoveLabel);
    await tester.pump();
    await tester.tapButton(tester.l10n.snapActionCancelLabel);
    await tester.pump();

    verify(packageKit.cancelTransaction(0)).called(1);
    expect(find.text(tester.l10n.snapActionRemovingLabel), findsOneWidget);
    expect(find.button(tester.l10n.snapActionRemoveLabel), findsNothing);

    transactionCompleter.completeError(
      PackageKitTransactionCancelled('cancelled'),
    );
    await tester.pumpAndSettle();
    verifyNever(errors.add(any));
    await tester.tapButton(tester.l10n.snapActionRemoveLabel);
    await tester.pumpAndSettle();

    verify(packageKit.remove(any, allowDeps: true)).called(2);
  });

  testWidgets('uninstall asks first when other packages depend on it', (
    tester,
  ) async {
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
      simulatedRemove: [
        const PackageKitPackageEvent(
          info: PackageKitInfo.removing,
          packageId: PackageKitPackageId(name: 'testdeb-plugin', version: '1'),
          summary: 'summary',
        ),
      ],
    );

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();
    await tester.tapButton(tester.l10n.snapActionRemoveLabel);
    await tester.pumpAndSettle();

    expect(find.text('testdeb-plugin'), findsOneWidget);
    verifyNever(packageKit.remove(any, allowDeps: anyNamed('allowDeps')));

    await tester.tap(find.button(tester.l10n.snapActionRemoveLabel).last);
    await tester.pumpAndSettle();

    verify(packageKit.remove(any, allowDeps: true)).called(1);
  });

  testWidgets('no uninstall for a package the desktop needs', (tester) async {
    createMockAppstreamService(
      components: [
        createAppstreamComponent(
          id: 'testdeb',
          packageName: 'testdeb',
          compulsoryForDesktops: ['GNOME'],
        ),
      ],
    );
    createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
    );

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          currentDesktopsProvider.overrideWithValue(['GNOME']),
        ],
        child: const LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    expect(find.button(tester.l10n.snapActionInstalledLabel), isDisabled);
    expect(find.button(tester.l10n.snapActionRemoveLabel), findsNothing);
  });

  testWidgets('install failing before a transaction starts shows an error', (
    tester,
  ) async {
    // ignore: close_sinks
    final errors = registerMockErrorStreamControllerService();
    final packageKit = createMockPackageKitService(packageDetails: mockPackage);
    when(
      packageKit.installLocal(any),
    ).thenAnswer((_) async => throw Exception('file was moved'));

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    await tester.tapButton(tester.l10n.snapActionInstallLabel);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.button(tester.l10n.snapActionInstallLabel),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      verify(errors.add(captureAny)).captured.single,
      isA<PackageKitServiceError>()
          .having((e) => e.code, 'code', PackageKitError.internalError)
          .having((e) => e.details, 'details', contains('file was moved')),
    );
    expect(find.button(tester.l10n.snapActionInstallLabel), isEnabled);
  });

  test('uninstall refreshes the packages and updates for Manage', () async {
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.0'),
        summary: 'summary',
      ),
    );
    final container = createContainer();
    container.listen(installedPackagesProvider, (_, __) {});
    container.listen(debsWithUpdatesProvider, (_, __) {});
    await container.read(installedPackagesProvider.future);
    await container.read(debsWithUpdatesProvider.future);
    const path = '/path/to/package.deb';
    await container.read(localDebModelProvider(path: path).future);

    await container.read(localDebModelProvider(path: path).notifier).remove();
    await container.read(installedPackagesProvider.future);
    await container.read(debsWithUpdatesProvider.future);

    verify(packageKit.getInstalledPackages()).called(2);
    verify(packageKit.getUpdates()).called(2);
  });

  for (final installedVersion in ['0.9', '1.1']) {
    testWidgets('install local 1.0 over installed $installedVersion', (
      tester,
    ) async {
      final packageKit = createMockPackageKitService(
        packageDetails: mockPackage,
        packageInfo: PackageKitPackageInfo(
          info: PackageKitInfo.installed,
          packageId: PackageKitPackageId(
            name: 'testdeb',
            version: installedVersion,
          ),
          summary: 'summary',
        ),
      );

      await tester.pumpApp(
        (_) => const ProviderScope(
          child: LocalDebPage(path: '/path/to/package.deb'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.button(tester.l10n.snapActionInstalledLabel), findsNothing);
      expect(find.button(tester.l10n.snapActionInstallLabel), isEnabled);
      expect(find.button(tester.l10n.snapActionRemoveLabel), isEnabled);
      expect(
        find.text(tester.l10n.localDebInstalledVersion(installedVersion)),
        findsOneWidget,
      );

      await tester.tapButton(tester.l10n.snapActionInstallLabel);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.button(tester.l10n.snapActionInstallLabel),
        ),
      );
      await tester.pumpAndSettle();

      verify(packageKit.installLocal('/path/to/package.deb')).called(1);
    });
  }

  testWidgets('does not present an available version as installed', (
    tester,
  ) async {
    createMockPackageKitService(
      packageDetails: mockPackage,
      packageInfo: const PackageKitPackageInfo(
        info: PackageKitInfo.available,
        packageId: PackageKitPackageId(name: 'testdeb', version: '1.1'),
        summary: 'summary',
      ),
    );
    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.button(tester.l10n.snapActionInstallLabel), isEnabled);
    expect(find.button(tester.l10n.snapActionRemoveLabel), findsNothing);
    expect(
      find.text(tester.l10n.localDebInstalledVersion('1.1')),
      findsNothing,
    );
  });

  testWidgets('install', (tester) async {
    final transactionCompleter = Completer();
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      waitTransaction: transactionCompleter.future,
    );
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    await tester.tapButton(tester.l10n.snapActionInstallLabel);
    await tester.pump();

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.button(tester.l10n.snapActionInstallLabel),
      ),
    );
    await tester.pump();

    verify(packageKit.installLocal('/path/to/package.deb')).called(1);
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);

    transactionCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.byType(YaruCircularProgressIndicator), findsNothing);
  });

  testWidgets('warning link shows a pointer cursor on hover', (tester) async {
    final packageKit = createMockPackageKitService(packageDetails: mockPackage);
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      pointer: 1,
    );
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(
      tester.getCenter(find.text(tester.l10n.localDebLearnMore)),
    );
    await tester.pump();

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.click,
    );
  });
}
