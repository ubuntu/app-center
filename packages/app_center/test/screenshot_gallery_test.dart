import 'package:app_center/widgets/screenshot_gallery.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  const sampleUrls = [
    'https://example.com/1.png',
    'https://example.com/2.png',
  ];

  group('ScreenshotGallery', () {
    testWidgets('renders navigation controls for multiple urls in LTR', (
      tester,
    ) async {
      await tester.pumpApp(
        (_) => const ScreenshotGallery(
          title: 'Test App',
          urls: sampleUrls,
        ),
      );

      await tester.pump();

      expect(find.byType(ScreenshotGallery), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(2));

      // In LTR: Previous (<) is disabled at page 0, Next (>) is enabled
      final prevBtn = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.byIcon(YaruIcons.go_previous),
          matching: find.byType(OutlinedButton),
        ),
      );
      final nextBtn = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.byIcon(YaruIcons.go_next),
          matching: find.byType(OutlinedButton),
        ),
      );

      expect(prevBtn.onPressed, isNull);
      expect(nextBtn.onPressed, isNotNull);
    });

    testWidgets('adapts directional navigation controls in RTL context', (
      tester,
    ) async {
      await tester.pumpApp(
        (_) => const Directionality(
          textDirection: TextDirection.rtl,
          child: ScreenshotGallery(
            title: 'Test App',
            urls: sampleUrls,
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ScreenshotGallery), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(2));

      // In RTL: Flow moves right-to-left.
      // Next is on the left pointing left (<) and is enabled at page 0.
      // Previous is on the right pointing right (>) and is disabled at page 0.
      final nextBtn = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.byIcon(YaruIcons.go_previous),
          matching: find.byType(OutlinedButton),
        ),
      );
      final prevBtn = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.byIcon(YaruIcons.go_next),
          matching: find.byType(OutlinedButton),
        ),
      );

      expect(nextBtn.onPressed, isNotNull);
      expect(prevBtn.onPressed, isNull);

      // Tapping Next advances to next page
      await tester.tap(
        find.ancestor(
          of: find.byIcon(YaruIcons.go_previous),
          matching: find.byType(OutlinedButton),
        ),
      );
      await tester.pumpAndSettle();

      // Now at page 1: Next (<) is disabled, Previous (>) is enabled
      final nextBtnAfter = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.byIcon(YaruIcons.go_previous),
          matching: find.byType(OutlinedButton),
        ),
      );
      final prevBtnAfter = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.byIcon(YaruIcons.go_next),
          matching: find.byType(OutlinedButton),
        ),
      );

      expect(nextBtnAfter.onPressed, isNull);
      expect(prevBtnAfter.onPressed, isNotNull);
    });

    testWidgets('hides navigation controls for a single url', (tester) async {
      await tester.pumpApp(
        (_) => const ScreenshotGallery(
          title: 'Test App',
          urls: ['https://example.com/1.png'],
        ),
      );

      await tester.pump();

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets(
      'dialog adapts directional navigation controls in RTL context',
      (
        tester,
      ) async {
        await tester.pumpApp(
          (_) => const Directionality(
            textDirection: TextDirection.rtl,
            child: ScreenshotGallery(
              title: 'Test App',
              urls: sampleUrls,
            ),
          ),
        );

        await tester.pump();

        // Open dialog
        await tester.tap(find.byType(MediaTile).first);
        await tester.pumpAndSettle();

        expect(find.byType(SimpleDialog), findsOneWidget);

        final dialogButtons = find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.byType(OutlinedButton),
        );
        expect(dialogButtons, findsNWidgets(2));
      },
    );
  });
}
