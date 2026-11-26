import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/unified_app_page.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

const _entry = AppDetailsEntry.snap('testsnap');
const _debEntry = AppDetailsEntry.debComponent('org.test.app');

void main() {
  tearDown(resetAllServices);

  late Completer<ResolvedAppIdentity> lookup;

  /// Opens the page with the identity lookup still running.
  Future<void> pumpPage(
    WidgetTester tester, {
    ObservedOperation? activeOperation,
    bool deb = false,
  }) async {
    final entry = deb ? _debEntry : _entry;
    lookup = Completer();
    final backend = FakePackageDetailsBackend();
    final container = createContainer(
      overrides: [
        packageDetailsBackendsProvider.overrideWithValue({
          PackageFormat.snap: backend,
          PackageFormat.deb: backend,
        }),
        appDetailsIdentityProvider(entry).overrideWith((ref) => lookup.future),
        appDetailsRatingsProvider(
          'testsnap',
        ).overrideWith((ref) => const AsyncData(null)),
        fakeSnapshotProvider(testSnapKey).overrideWith(
          (ref) => AsyncData(
            createSourceSnapshot(testSnapKey, activeOperation: activeOperation),
          ),
        ),
        fakeSnapshotProvider(testDebKey).overrideWith(
          (ref) => AsyncData(
            createSourceSnapshot(testDebKey, activeOperation: activeOperation),
          ),
        ),
      ],
    );
    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: UnifiedAppPage(entry: entry),
      ),
    );
    await tester.pump();
  }

  Future<void> finishLookup(WidgetTester tester, {bool deb = false}) async {
    lookup.complete(createResolvedIdentity(snap: !deb, deb: deb));
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

  testWidgets('wraps the page content in a single selection area', (
    tester,
  ) async {
    await pumpPage(tester);
    await finishLookup(tester);

    expect(find.byType(SelectionArea), findsOneWidget);
    for (final sample in [
      find.text('Snap summary'),
      find.text('Snap description'),
      find.text('MIT'),
    ]) {
      expect(
        find.ancestor(of: sample, matching: find.byType(SelectionArea)),
        findsOneWidget,
      );
    }
    // The markdown description joins the page-wide selection instead of
    // creating one selectable text per paragraph.
    expect(find.byType(SelectableText), findsNothing);
  });

  testWidgets('deb descriptions join the page selection', (tester) async {
    await pumpPage(tester, deb: true);
    await finishLookup(tester, deb: true);

    expect(find.byType(Html), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Deb description'),
        matching: find.byType(SelectionArea),
      ),
      findsOneWidget,
    );
  });

  testWidgets('action buttons are excluded from the selection', (tester) async {
    await pumpPage(tester);
    await finishLookup(tester);

    // Page text has a selection registrar above it, but the action buttons
    // are wrapped in a disabled selection container, so they have none.
    final install = tester.element(
      find.text(tester.l10n.snapActionInstallLabel),
    );
    expect(SelectionContainer.maybeOf(install), isNull);
    final summary = tester.element(find.text('Snap summary'));
    expect(SelectionContainer.maybeOf(summary), isNotNull);
  });

  testWidgets('selecting across page sections copies text from all of them', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    final clipboardCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (message) async {
        clipboardCalls.add(message);
        return message.method == 'Clipboard.getData'
            ? <String, dynamic>{'text': ''}
            : null;
      },
    );

    await pumpPage(tester);
    await finishLookup(tester);

    final start = tester.getCenter(find.text('Snap summary'));
    final end = tester.getCenter(find.text('Snap description'));
    final gesture = await tester.startGesture(
      start,
      kind: PointerDeviceKind.mouse,
    );
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy((end - start) / 10);
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    final setData = clipboardCalls
        .where((call) => call.method == 'Clipboard.setData')
        .toList();
    expect(setData, isNotEmpty);
    final copied = setData.single.arguments as Map;
    // The selection starts and ends mid-word, so only check the parts of
    // both sections that the dragged range must cover.
    expect(copied['text'] as String, contains('mmary'));
    expect(copied['text'] as String, contains('Snap de'));

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('keeps scrolling with the mouse wheel and the keyboard', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    await pumpPage(tester);
    await finishLookup(tester);

    // Shrink the window so the page content overflows.
    tester.view.physicalSize =
        (const Size(800, 250) + const Offset(54, 54)) *
        tester.view.devicePixelRatio;
    await tester.pump();

    final position = Scrollable.of(tester.element(find.text('Snap summary')))
        .position;
    expect(position.maxScrollExtent, greaterThan(0));

    // Mouse wheel. After shrinking the window, the summary is below the
    // fold, so the events target the visible app title.
    final visibleText = find.text('Snap App');
    await tester.sendEventToBinding(
      PointerScrollEvent(
        scrollDelta: const Offset(0, 60),
        position: tester.getCenter(visibleText),
      ),
    );
    await tester.pump();
    expect(position.pixels, greaterThan(0));
    position.jumpTo(0);

    // PageDown while the selection area has the focus.
    final click = await tester.startGesture(
      tester.getCenter(visibleText),
      kind: PointerDeviceKind.mouse,
    );
    await click.up();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(position.pixels, greaterThan(0));

    debugDefaultTargetPlatformOverride = null;
  });
}
