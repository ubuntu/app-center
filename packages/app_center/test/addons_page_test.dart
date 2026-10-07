import 'package:app_center/addons/addons.dart';
import 'package:app_center/snapd/snap_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  Future<void> pumpAddonsPage(
    WidgetTester tester, {
    SnapLauncher? firmwareLauncher,
    Object? firmwareError,
  }) async {
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          firmwareUpdaterLauncherProvider.overrideWith(
            (_) async =>
                firmwareError != null ? throw firmwareError : firmwareLauncher,
          ),
        ],
        child: const AddonsPage(),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders Additional drivers tile when drivers are available', (
    tester,
  ) async {
    registerMockDriversService();
    await pumpAddonsPage(tester);

    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversTitle),
      findsOneWidget,
    );
    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversDescription),
      findsOneWidget,
    );
    expect(find.byIcon(YaruIcons.go_next), findsNWidgets(3));
  });

  testWidgets('hides Additional drivers tile when drivers are unavailable', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    await pumpAddonsPage(tester);

    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversTitle),
      findsNothing,
    );
    expect(find.byIcon(YaruIcons.go_next), findsNWidgets(2));
  });

  testWidgets('links to the firmware updater snap when not installed', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    await pumpAddonsPage(tester);

    expect(find.text(tester.l10n.addonsPageFirmwareTitle), findsOneWidget);
    expect(
      find.text(tester.l10n.addonsPageFirmwareDescription),
      findsOneWidget,
    );
    expect(find.byIcon(YaruIcons.external_link), findsNothing);
  });

  testWidgets('links to the firmware updater snap when snapd fails', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    await pumpAddonsPage(
      tester,
      firmwareError: SnapdException(message: 'offline'),
    );

    expect(find.text(tester.l10n.addonsPageFirmwareTitle), findsOneWidget);
    expect(find.byIcon(YaruIcons.external_link), findsNothing);
    expect(find.byIcon(YaruIcons.go_next), findsNWidgets(2));
  });

  testWidgets('launches the firmware updater when installed', (tester) async {
    registerMockDriversService(available: false);
    final launcher = createMockSnapLauncher(isLaunchable: true);
    await pumpAddonsPage(tester, firmwareLauncher: launcher);

    expect(find.byIcon(YaruIcons.external_link), findsOneWidget);

    await tester.tap(find.text(tester.l10n.addonsPageFirmwareTitle));
    await tester.pump();

    verify(launcher.open()).called(1);
  });
}
