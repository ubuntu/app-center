import 'package:app_center/layout.dart';
import 'package:app_center/snapd/snap_category_enum.dart';
import 'package:app_center/snapd/snap_search.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  testWidgets('banner icons expose one label each, slogan stays separate', (
    tester,
  ) async {
    final mockSearchProvider = createMockSnapSearchProvider({
      const SnapSearchParameters(category: SnapCategoryEnum.artAndDesign): [
        createSnap(name: 'gimp', title: 'GIMP'),
        createSnap(name: 'krita', title: 'Krita'),
      ],
    });
    final semantics = tester.ensureSemantics();
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          snapSearchProvider.overrideWith(
            (ref, arg) => mockSearchProvider(arg),
          ),
        ],
        child: ResponsiveLayoutBuilder(
          builder: (_) => const CategoryBanner(
            category: SnapCategoryEnum.artAndDesign,
          ),
        ),
      ),
    );
    // The banner hides its icons on small layouts; widen the window so the
    // icons render. physicalSize is in physical pixels, so scale by the
    // device pixel ratio (3.0 in tests) to get a 1400x900 logical window.
    tester.view.physicalSize =
        const Size(1400, 900) * tester.view.devicePixelRatio;
    await tester.pumpAndSettle();

    final slogan = tester.l10n.snapCategoryArtAndDesignSlogan;
    expect(find.bySemanticsLabel(slogan), findsOneWidget);

    for (final title in ['GIMP', 'Krita']) {
      final icon = find.bySemanticsLabel(title);
      expect(icon, findsOneWidget);
      // The InkWell contributes tap/focus actions and focusability, not the
      // isButton flag, so assert the actions the node actually carries.
      expect(
        tester.getSemantics(icon),
        matchesSemantics(
          label: title,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    }
    semantics.dispose();
  });
}
