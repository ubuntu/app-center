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
    // icons render.
    tester.view.physicalSize = const Size(1400, 900);
    await tester.pumpAndSettle();

    final slogan = tester.l10n.snapCategoryArtAndDesignSlogan;
    expect(find.bySemanticsLabel(slogan), findsOneWidget);

    for (final title in ['GIMP', 'Krita']) {
      final icon = find.bySemanticsLabel(title);
      expect(icon, findsOneWidget);
      expect(
        tester.getSemantics(icon),
        matchesSemantics(label: title, isButton: true),
      );
    }
    semantics.dispose();
  });
}
