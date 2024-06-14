import 'dart:async';

import 'package:app_center/deb/deb.dart';
import 'package:app_center/l10n/l10n.dart';
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
    expect(find.text('url'), findsOneWidget);
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

    expect(find.button(tester.l10n.snapActionInstallLabel), isDisabled);
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
}
