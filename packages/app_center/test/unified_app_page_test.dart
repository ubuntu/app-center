import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/unified_app_page.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

const _entry = AppDetailsEntry.snap('testsnap');

void main() {
  tearDown(resetAllServices);

  late Completer<ResolvedAppIdentity> lookup;

  /// Opens the page with the identity lookup still running.
  Future<void> pumpPage(
    WidgetTester tester, {
    ObservedOperation? activeOperation,
  }) async {
    lookup = Completer();
    final backend = FakePackageDetailsBackend();
    final container = createContainer(
      overrides: [
        packageDetailsBackendsProvider.overrideWithValue({
          PackageFormat.snap: backend,
          PackageFormat.deb: backend,
        }),
        appDetailsIdentityProvider(_entry).overrideWith((ref) => lookup.future),
        appDetailsRatingsProvider(
          'testsnap',
        ).overrideWith((ref) => const AsyncData(null)),
        fakeSnapshotProvider(testSnapKey).overrideWith(
          (ref) => AsyncData(
            createSourceSnapshot(testSnapKey, activeOperation: activeOperation),
          ),
        ),
      ],
    );
    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: const UnifiedAppPage(entry: _entry),
      ),
    );
    await tester.pump();
  }

  Future<void> finishLookup(WidgetTester tester) async {
    lookup.complete(createResolvedIdentity(deb: false));
    // The icon's loading shimmer never stops, so pumpAndSettle would time out.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows only a spinner and no format menu until decided', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);
    expect(find.byType(YaruSplitButton), findsNothing);
    expect(find.byIcon(YaruIcons.view_more), findsNothing);

    await finishLookup(tester);

    expect(find.byType(YaruCircularProgressIndicator), findsNothing);
    expect(find.text(tester.l10n.snapActionInstallLabel), findsOneWidget);
    expect(find.byIcon(YaruIcons.view_more), findsOneWidget);
  });

  testWidgets('hides a running change until decided', (tester) async {
    await pumpPage(
      tester,
      activeOperation: const ObservedOperation(
        kind: OperationKind.install,
        targetId: 'latest/stable',
        progress: 0.4,
      ),
    );
    expect(find.byType(ActiveChangeStatus), findsNothing);

    await finishLookup(tester);
    expect(find.byType(ActiveChangeStatus), findsOneWidget);
  });
}
