import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/snapd/snap_data.dart';
import 'package:app_center/widgets/app_info_bar.dart';
import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    registerMockRatingsService();
    registerMockSnapdService();
  });
  tearDown(resetAllServices);

  group('SnapInfoBar', () {
    testWidgets('links can receive keyboard focus', (tester) async {
      final snapData = SnapData(
        name: 'testsnap',
        localSnap: null,
        storeSnap: createSnap(
          name: 'testsnap',
          version: '1.0.0',
          website: 'https://example.com',
        ),
      );

      await tester.pumpApp(
        (_) => ProviderScope(
          child: ResponsiveLayoutBuilder(
            builder: (_) => SnapInfoBar(snapData: snapData),
          ),
        ),
      );
      await tester.pump();

      await expectLinkFocusable(tester);
    });
  });

  group('DebInfoBar', () {
    testWidgets('links can receive keyboard focus', (tester) async {
      final subscription = const Stream<PackageKitServiceError>.empty().listen(
        null,
      );
      addTearDown(subscription.cancel);
      final debData = DebData(
        id: 'test.deb',
        component: const AppstreamComponent(
          id: 'test.deb',
          type: AppstreamComponentType.desktopApplication,
          package: 'testdeb',
          name: {'C': 'Test Deb'},
          summary: {'C': 'Test Deb Summary'},
          urls: [
            AppstreamUrl(
              'https://example.com',
              type: AppstreamUrlType.homepage,
            ),
          ],
        ),
        hasUpdate: false,
        errorStream: subscription,
      );

      await tester.pumpApp(
        (_) => ProviderScope(
          child: ResponsiveLayoutBuilder(
            builder: (_) => DebInfoBar(debData: debData),
          ),
        ),
      );
      await tester.pump();

      await expectLinkFocusable(tester);
    });
  });
}

/// Verifies that the link rendered by the info bar can receive keyboard
/// focus: the wrapping [SelectionArea] must not block focus, the link's
/// focus node must accept focus, and tabbing must reach the link.
Future<void> expectLinkFocusable(WidgetTester tester) async {
  final link = find.byType(HyperlinkText);
  expect(link, findsOneWidget);

  // The SelectionArea wrapping the link must not disable focus.
  for (final area in tester.widgetList<SelectionArea>(
    find.byType(SelectionArea),
  )) {
    expect(area.focusNode?.canRequestFocus, isNot(isFalse));
  }

  final linkText = find.descendant(of: link, matching: find.byType(Text));
  final focusNode = Focus.of(tester.element(linkText));
  expect(focusNode.canRequestFocus, isTrue);

  // Tabbing through the page reaches the link.
  var reachedByTab = false;
  for (var i = 0; i < 20 && !reachedByTab; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    reachedByTab = focusNode.hasFocus;
  }
  expect(reachedByTab, isTrue);

  // The link also gains focus when focus is requested directly.
  focusNode.requestFocus();
  await tester.pump();
  expect(focusNode.hasFocus, isTrue);
}
