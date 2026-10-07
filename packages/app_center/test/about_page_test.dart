import 'package:app_center/about/about_page.dart';
import 'package:app_center/about/about_providers.dart';
import 'package:app_center/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  testWidgets('about page shows contributors when loaded', (tester) async {
    final contributors = [
      Contributor(login: 'user1', htmlUrl: 'https://github.com/user1'),
      Contributor(login: 'user2', htmlUrl: 'https://github.com/user2'),
    ];

    await tester.pumpApp(
      (context) => ProviderScope(
        overrides: [
          contributorsProvider(
            kGitHubRepo,
          ).overrideWith((_) async => contributors),
        ],
        child: const AboutPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('App Center'), findsOneWidget);
    expect(find.byTooltip('user1'), findsOneWidget);
    expect(find.byTooltip('user2'), findsOneWidget);
  });

  testWidgets('about page gracefully handles contributor error', (
    tester,
  ) async {
    await tester.pumpApp(
      (context) => ProviderScope(
        overrides: [
          contributorsProvider(
            kGitHubRepo,
          ).overrideWith((_) => throw Exception('Network error')),
        ],
        child: const AboutPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('App Center'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('Network error'), findsNothing);
  });
}
