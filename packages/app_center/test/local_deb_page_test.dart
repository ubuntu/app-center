import 'dart:async';

import 'package:app_center/deb/deb.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter/material.dart';
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
  });

  testWidgets('architecture mismatch disables install', (tester) async {
    final amd64Package = PackageKitPackageDetails(
      packageId: const PackageKitPackageId(
        name: 'testdeb',
        version: '1.0',
        arch: 'amd64',
      ),
      summary: 'summary',
      description: 'description',
      license: 'license',
      size: 42,
      url: 'url',
    );
    final packageKit = createMockPackageKitService(
      packageDetails: amd64Package,
      nativeArchitecture: 'arm64',
    );
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pump();

    // The package details stay fully visible...
    expect(find.text('testdeb'), findsOneWidget);
    expect(find.text('summary'), findsOneWidget);
    expect(find.text('description'), findsOneWidget);
    // ...while installing is disabled, with the reason shown in the banner.
    expect(find.text(tester.l10n.localDebArchMismatchTitle), findsOneWidget);
    expect(find.textContaining('amd64'), findsOneWidget);
    expect(find.textContaining('arm64'), findsOneWidget);
    expect(find.button(tester.l10n.snapActionInstallLabel), isDisabled);
    verifyNever(packageKit.installLocal(any));
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

  testWidgets('install failure surfaces an error and clears the spinner', (
    tester,
  ) async {
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      errorStream: Stream.value(
        const PackageKitServiceError(
          code: PackageKitError.internalError,
          details: 'install failed',
        ),
      ),
    );
    registerMockService<PackageKitService>(packageKit);

    await tester.pumpApp(
      (_) => const ProviderScope(
        child: LocalDebPage(path: '/path/to/package.deb'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('PackageKit error: ${PackageKitError.internalError}'),
      findsOneWidget,
    );
    expect(find.text('install failed'), findsOneWidget);
    expect(find.byType(YaruCircularProgressIndicator), findsNothing);
    expect(find.button(tester.l10n.snapActionInstallLabel), findsOneWidget);
  });

  testWidgets('a failed transaction re-enables the install button', (
    tester,
  ) async {
    final packageKit = createMockPackageKitService(packageDetails: mockPackage);
    when(packageKit.waitTransaction(any)).thenAnswer(
      (_) => Future<void>.error(
        PackageKitTransactionError('Transaction 0 was destroyed'),
      ),
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
    await tester.pumpAndSettle();

    verify(packageKit.installLocal('/path/to/package.deb')).called(1);
    expect(find.byType(YaruCircularProgressIndicator), findsNothing);
    expect(find.button(tester.l10n.snapActionInstallLabel), findsOneWidget);
  });

  testWidgets('a failed install shows the error dialog only once', (
    tester,
  ) async {
    // A real PackageKit failure emits an ErrorCode signal (via errorStream)
    // *and* finishes the transaction with a non-success exit (waitTransaction
    // throws). Both must resolve to a single error dialog, not two stacked
    // copies.
    final errorController =
        StreamController<PackageKitServiceError>.broadcast();
    addTearDown(errorController.close);
    final waitCompleter = Completer<void>();
    final packageKit = createMockPackageKitService(
      packageDetails: mockPackage,
      errorStream: errorController.stream,
    );
    when(
      packageKit.waitTransaction(any),
    ).thenAnswer((_) => waitCompleter.future);
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

    // ErrorCode signal first...
    errorController.add(
      const PackageKitServiceError(
        code: PackageKitError.internalError,
        details: 'install failed',
      ),
    );
    await tester.pumpAndSettle();
    // ...then the transaction finishes with a failure exit.
    waitCompleter.completeError(
      PackageKitTransactionError('Transaction 0 finished with exit failed'),
    );
    await tester.pumpAndSettle();

    expect(find.text('install failed'), findsOneWidget);
  });
}
