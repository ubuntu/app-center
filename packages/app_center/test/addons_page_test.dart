import 'package:app_center/addons/addons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  testWidgets('renders Additional drivers tile when drivers are available', (
    tester,
  ) async {
    registerMockDriversService();
    await tester.pumpApp(
      (_) => const ProviderScope(child: AddonsPage()),
    );
    await tester.pump();

    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversTitle),
      findsOneWidget,
    );
    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversDescription),
      findsOneWidget,
    );
    expect(find.byIcon(YaruIcons.go_next), findsOneWidget);
  });

  testWidgets('hides Additional drivers tile when drivers are unavailable', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    await tester.pumpApp(
      (_) => const ProviderScope(child: AddonsPage()),
    );
    await tester.pump();

    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversTitle),
      findsNothing,
    );
  });
}
