import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/app_info_bar.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
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
    testWidgets('renders SelectionArea allowing keyboard focus', (tester) async {
      final snap = createSnap(
        name: 'testsnap',
        version: '1.0.0',
        website: 'https://example.com',
      );
      final snapData = SnapData(
        name: 'testsnap',
        storeSnap: snap,
      );

      await tester.pumpApp(
        (_) => ProviderScope(
          child: SnapInfoBar(snapData: snapData),
        ),
      );
      await tester.pump();

      final selectionAreas = find.byType(SelectionArea);
      expect(selectionAreas, findsWidgets);

      // Verify SelectionAreas do not have focus disabled
      for (final element in tester.widgetList<SelectionArea>(selectionAreas)) {
        expect(element.focusNode?.canRequestFocus, isNot(isFalse));
      }
    });
  });

  group('DebInfoBar', () {
    testWidgets('renders SelectionArea allowing keyboard focus', (tester) async {
      final debData = DebData(
        component: AppstreamComponent(
          id: 'test.deb',
          name: 'Test Deb',
          summary: 'Test Deb Summary',
          pkgname: 'testdeb',
          version: '1.0',
        ),
      );

      await tester.pumpApp(
        (_) => ProviderScope(
          child: DebInfoBar(debData: debData),
        ),
      );
      await tester.pump();

      final selectionAreas = find.byType(SelectionArea);
      expect(selectionAreas, findsWidgets);

      for (final element in tester.widgetList<SelectionArea>(selectionAreas)) {
        expect(element.focusNode?.canRequestFocus, isNot(isFalse));
      }
    });
  });
}
