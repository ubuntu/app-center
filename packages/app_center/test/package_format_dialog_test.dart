import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/unified_app_page.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

const _entry = AppDetailsEntry.snap('testsnap');

void main() {
  tearDown(resetAllServices);

  late FakePackageDetailsBackend backend;

  setUp(() => backend = FakePackageDetailsBackend());

  Future<void> pumpDialog(
    WidgetTester tester, {
    required PackageSourceSnapshot snap,
    required PackageSourceSnapshot deb,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageDetailsBackendsProvider.overrideWithValue({
            PackageFormat.snap: backend,
            PackageFormat.deb: backend,
          }),
          appDetailsIdentityProvider(
            _entry,
          ).overrideWith((ref) async => createResolvedIdentity()),
          appDetailsRatingsProvider(
            'testsnap',
          ).overrideWith((ref) => const AsyncData(null)),
          fakeSnapshotProvider(
            testSnapKey,
          ).overrideWith((ref) => AsyncData(snap)),
          fakeSnapshotProvider(
            testDebKey,
          ).overrideWith((ref) => AsyncData(deb)),
        ],
        child: const MaterialApp(
          localizationsDelegates: localizationsDelegates,
          home: Scaffold(body: PackageFormatDialog(entry: _entry)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists every format without a warning when none installed', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
    );
    final l10n = tester.l10n;

    expect(find.text(l10n.appDetailsChoosePackageFormatTitle), findsOneWidget);
    expect(find.text(l10n.managePagePackageTypeSnap), findsOneWidget);
    expect(find.text(l10n.managePagePackageTypeDeb), findsOneWidget);
    expect(find.text(l10n.appDetailsPackageSourceSnapStore), findsOneWidget);
    expect(find.text('latest/stable'), findsOneWidget);
    expect(find.text('2.0'), findsOneWidget);
    expect(find.text('1.0-1'), findsOneWidget);
    expect(find.text(l10n.snapActionInstallLabel), findsNWidgets(2));
    expect(find.text(l10n.appDetailsPackageFormatDataNotShared), findsNothing);
    expect(find.text(l10n.appDetailsPackageFormatsLearnMore), findsOneWidget);
  });

  testWidgets('warns about the installed format and installs another', (
    tester,
  ) async {
    await pumpDialog(
      tester,
      snap: createSourceSnapshot(
        testSnapKey,
        installState: InstallState.installed,
      ),
      deb: createSourceSnapshot(testDebKey),
    );
    final l10n = tester.l10n;

    expect(
      find.text(
        l10n.appDetailsInstalledAsFormat(l10n.managePagePackageTypeSnap),
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.snapActionInstalledLabel), findsOneWidget);
    expect(find.text(l10n.snapActionRemoveLabel), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.snapActionInstallLabel));
    await tester.tap(find.text(l10n.snapActionInstallLabel));
    await tester.pump();

    final (key, command) = backend.executed.single;
    expect(key, testDebKey);
    expect(command.kind, OperationKind.install);
    expect(command.candidateId, testDebCandidate.candidateId);
    expect(find.text(l10n.snapActionInstallingLabel), findsOneWidget);
  });

  testWidgets('warns when several formats are installed', (tester) async {
    await pumpDialog(
      tester,
      snap: createSourceSnapshot(
        testSnapKey,
        installState: InstallState.installed,
      ),
      deb: createSourceSnapshot(
        testDebKey,
        installState: InstallState.installed,
      ),
    );
    final l10n = tester.l10n;

    expect(
      find.text(l10n.appDetailsInstalledAsMultipleFormats),
      findsOneWidget,
    );
    expect(find.text(l10n.snapActionRemoveLabel), findsNWidgets(2));
  });
}
