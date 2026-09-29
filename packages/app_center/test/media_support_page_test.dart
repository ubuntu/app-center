import 'dart:async';

import 'package:app_center/media_support/media_support.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_test/yaru_test.dart';

import 'test_utils.dart';

PackageKitPackageEvent _package(String name, PackageKitInfo info) =>
    PackageKitPackageEvent(
      packageId: PackageKitPackageId(name: name, version: '1.0'),
      info: info,
      summary: name,
    );

void main() {
  tearDown(resetAllServices);

  testWidgets('install missing packages even when an update is available', (
    tester,
  ) async {
    final kit = createMockPackageKitService(
      resolveMap: {
        mediaSupportPackages.first: _package(
          mediaSupportPackages.first,
          PackageKitInfo.installed,
        ),
        mediaSupportPackages.last: _package(
          mediaSupportPackages.last,
          PackageKitInfo.available,
        ),
      },
      availableUpdates: [
        _package(mediaSupportPackages.first, PackageKitInfo.normal),
      ],
    );
    await tester.pumpApp((_) => const ProviderScope(child: MediaSupportPage()));
    await tester.pumpAndSettle();
    expect(find.button(tester.l10n.snapActionInstallLabel), findsOneWidget);
    expect(find.button(tester.l10n.snapActionUpdateLabel), findsNothing);
    await tester.tap(find.button(tester.l10n.snapActionInstallLabel));
    await tester.pumpAndSettle();
    verify(kit.installAll(any)).called(1);
  });

  testWidgets('shows update for installed packages with an update', (
    tester,
  ) async {
    createMockPackageKitService(
      resolveMap: {
        for (final name in mediaSupportPackages)
          name: _package(name, PackageKitInfo.installed),
      },
      availableUpdates: [
        _package(mediaSupportPackages.last, PackageKitInfo.normal),
      ],
    );
    await tester.pumpApp((_) => const ProviderScope(child: MediaSupportPage()));
    await tester.pumpAndSettle();
    expect(find.button(tester.l10n.snapActionUpdateLabel), findsOneWidget);
  });

  testWidgets('shows uninstall when all packages are installed', (
    tester,
  ) async {
    createMockPackageKitService(
      resolveMap: {
        for (final name in mediaSupportPackages)
          name: _package(name, PackageKitInfo.installed),
      },
    );
    await tester.pumpApp((_) => const ProviderScope(child: MediaSupportPage()));
    await tester.pumpAndSettle();
    expect(find.button(tester.l10n.snapActionRemoveLabel), findsOneWidget);
  });

  testWidgets('shows active status and cancel while installing', (
    tester,
  ) async {
    final kit = createMockPackageKitService(transactionId: 6);
    final pending = Completer<void>();
    when(kit.waitTransaction(6)).thenAnswer((_) => pending.future);
    await tester.pumpApp((_) => const ProviderScope(child: MediaSupportPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.button(tester.l10n.snapActionInstallLabel));
    await tester.pump();
    expect(find.text(tester.l10n.snapActionInstallingLabel), findsOneWidget);
    expect(find.button(tester.l10n.snapActionCancelLabel), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows error and retry after failed install', (tester) async {
    final kit = createMockPackageKitService(transactionId: 8);
    when(kit.waitTransaction(8)).thenThrow(
      PackageKitTransactionError('failed', exit: PackageKitExit.failed),
    );
    await tester.pumpApp((_) => const ProviderScope(child: MediaSupportPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.button(tester.l10n.snapActionInstallLabel));
    await tester.pumpAndSettle();
    expect(find.text(tester.l10n.driversPageErrorLabel), findsOneWidget);
    expect(find.button(tester.l10n.driversPageRetryLabel), findsOneWidget);
    when(kit.waitTransaction(8)).thenAnswer((_) async {});
    await tester.tap(find.button(tester.l10n.driversPageRetryLabel));
    await tester.pumpAndSettle();
    verify(kit.installAll(any)).called(2);
  });
}
