import 'package:app_center/addons/addons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  testWidgets('renders Additional drivers tile', (tester) async {
    await tester.pumpApp((_) => const AddonsPage());
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
}
