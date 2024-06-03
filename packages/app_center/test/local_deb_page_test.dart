import 'dart:async';

import 'package:app_center/deb.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/packagekit.dart';
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

    expect(find.text('Name: testdeb'), findsOneWidget);
    expect(find.text('Summary: summary'), findsOneWidget);
    expect(find.text('Description: description'), findsOneWidget);
    expect(find.text('License: license'), findsOneWidget);
    expect(find.text('Size: ${tester.context.formatByteSize(42)}'),
        findsOneWidget);
    expect(find.text('URL: url'), findsOneWidget);
    expect(find.button('Install'), findsOneWidget);
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

    await tester.tapButton('Install');
    await tester.pump();

    verify(packageKit.installLocal('/path/to/package.deb')).called(1);
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);

    transactionCompleter.complete();
    await tester.pumpAndSettle();
    expect(find.byType(YaruCircularProgressIndicator), findsNothing);
  });
}
