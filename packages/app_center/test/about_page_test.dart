import 'package:app_center/about/about_providers.dart';
import 'package:app_center/about/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github/github.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  testWidgets('about page shows contributors when loaded', (tester) async {
    final contributors = [
      Contributor(login: 'user1', htmlUrl: 'https://github.com/user1'),
      Contributor(login: 'user2', htmlUrl: 'https://github.com/user2'),
    ];

    await tester.pumpApp(
      (context) => ProviderScope(
        overrides: [
          contributorsProvider('ubuntu/app-center')
              .overrideWith((_) async => contributors),
          versionProvider.overrideWith((_) async => '1.0.0'),
        ],
        child: const AboutPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('App Center'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
  });

  testWidgets('about page gracefully handles contributor error', (tester) async {
    await tester.pumpApp(
      (context) => ProviderScope(
        overrides: [
          contributorsProvider('ubuntu/app-center')
              .overrideWith((_) => throw Exception('Network error')),
          versionProvider.overrideWith((_) async => '1.0.0'),
        ],
        child: const AboutPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('App Center'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('Network error'), findsNothing);
  });
}
